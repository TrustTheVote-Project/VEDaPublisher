require 'csv'
class ElectionResultUpload < ActiveRecord::Base

  belongs_to :election_report, :class_name=>"Vedastore::ElectionReport"

  after_create :save_file
  
  def file=(file)
    @file = file
    self.file_name = file.respond_to?(:original_filename) ? file.original_filename : file.path
  end
  def file
    @file
  end
  
  def save_file
    File.open(path, "w+") do |f|
      str = file.read.scrub
      f.write str.force_encoding("ISO-8859-1").encode("UTF-8")
    end
  end
  
  def path
    dir = Rails.root.join('tmp', 'result_uploads', self.id.to_s)
    FileUtils.mkdir_p(dir)
    return dir.join(self.file_name)
  end
  
  def percent_complete
    (self.rows_processed.to_i * 100 / (self.row_count.to_i + 1)).to_i
  end
  
  def process!
    file = File.open(path)
    rows = CSV.parse(file.read.scrub, headers: true)
    file.close
    pending_rows = rows.length
    percent = 0
    self.update_attributes(row_count: pending_rows, rows_processed: 0)
    
    election = election_report.elections.includes([
      {:contests=>[
        :ballot_selections
      ]}
    ]).first
    
    gp_units = election_report.gp_units.inject({}) do |r, gp|
      r[gp.object_id] = gp
      r
    end
    
    contests = election.contests.inject({}) do |r, c| 
      r[c.object_id] = {
        contest: c,
        ballot_selections: c.ballot_selections.inject({}) {|bsr, bs| bsr[bs.object_id]=bs; bsr},
        parties: c.ballot_selections.inject({}){|bsr, bs| bsr[bs.local_party_code]=bs if bs.is_a?(Vedastore::Party); bsr},
        write_ins: {}
      }
      r
    end
    
    vc_list = []
    total_count_hash = {}
    contest_total_counts = {}
    
    puts "Done loading gp_units, contests and ballot selections"
    
    rows.each_with_index do |row, i|
      new_percent = (i * 100 / pending_rows).to_i
      if  new_percent > percent
        percent = new_percent
        self.update_attributes(rows_processed: i)
        puts self.rows_processed
      end
      if row["total_ballots"].to_i == 0
        next 
      end
      contest_id = row['Contest_Id']
      # TODO: shouldn't use elections.first
      contest_info = contests["contest-#{contest_id}"]
      contest = contest_info[:contest]
      
      
      
      candidate_id = row['candidate_id']
      candidate_type = row["Candidate_Type"].to_s.downcase # C vs W for write-in
      candidate_selection = nil
      if contest.is_a?(Vedastore::CandidateChoice)
        if candidate_type == "c"
          candidate_selection = contest_info[:ballot_selections]["candidate-selection-#{candidate_id}"]
        elsif candidate_type == "w"
          #Add a write-in option
          #see if it's already added
          writein_selection_id = "candidate-selection-writein-#{candidate_id}"
          candidate_selection = contest_info[:write_ins][writein_selection_id]
          if candidate_selection.nil?
            candidate_selection= Vedastore::CandidateSelection.new
            candidate_selection.is_write_in = true
            candidate_selection.object_id = writein_selection_id
            candidate_writein_id = "candidate-writein-#{candidate_id}"
            candidate_selection.candidate_selection_candidate_refs << Vedastore::CandidateSelectionCandidateRef.new(object_id: candidate_writein_id)
            election.candidates << Vedastore::Candidate.new(
              object_id: candidate_writein_id,
              ballot_name: row["candidate_name"]
            )
            election.save!
            contest.ballot_selections << candidate_selection
            contest.save!
            contest_info[:write_ins][writein_selection_id] = candidate_selection
          end
        end
      elsif contest.is_a?(Vedastore::StraightParty)
        candidate_selection = contest_info[:parties]["party-selection-#{candidate_id}"]
        # contest.ballot_selections.where(local_party_code: "party-selection-#{candidate_id}").first
      elsif contest.is_a?(Vedastore::BallotMeasure)
        candidate_selection = contest_info[:ballot_selections]["ballot-measure-selection-#{candidate_id}"]
      end
      if candidate_selection.nil?
        raise "No candidate selection for contest #{contest.type} #{contest.id}, candidate #{candidate_id}"
      end

      # find the precinct split with this ID

      ps = gp_units["vspub-precinct-split-#{row["Pct_Id"]}"]
      if ps.is_a?(Vedastore::ReportingUnit) && row["Reg_voters"].to_i > 0 && ps.registered_voters.to_i != row["Reg_voters"].to_i
        ps.update_attributes(registered_voters: row["Reg_voters"].to_i)
      end
      ccp = "#{contest_id}-#{candidate_id}-#{row["Pct_Id"]}"
    
      vc_a = Vedastore::VoteCount.new
      vc_e = Vedastore::VoteCount.new
      vc = Vedastore::VoteCount.new
      
      vc_e.gp_unit = vc.gp_unit = vc_a.gp_unit = ps.object_id
      vc_a.object_id = "votecount-#{ccp}-absentee"
      vc_a.ballot_type = Vedaspace::Enum::CountItemType.absentee
      vc_a.count = row["absentee_votes"]
      vc_e.object_id = "votecount-#{ccp}-early"
      vc_e.ballot_type = Vedaspace::Enum::CountItemType.early
      vc_e.count = row["early_votes"]
      vc.object_id = "votecount-#{ccp}-election-day"
      vc.ballot_type = Vedaspace::Enum::CountItemType.election_day
      vc.count = row["election_votes"]
      
      vc.ballot_selection_id = candidate_selection.id
      vc_a.ballot_selection_id = candidate_selection.id
      vc_e.ballot_selection_id = candidate_selection.id
      
      vc_list << vc
      vc_list << vc_a
      vc_list << vc_e
      
      
      total_count_by_gp_unit_id_total = "total-counts-#{ps.object_id}-#{contest_id}-#{Vedaspace::Enum::CountItemType.total.to_s}"
      if total_count_hash[total_count_by_gp_unit_id_total].nil?
        total_count = Vedastore::TotalCount.new        
        # absentee_ballots early_ballots	election_ballots        
        total_count.ballot_type = Vedastore::BallotType.total     
        total_count.gp_unit = ps.object_id
        total_count.object_id = total_count_by_gp_unit_id_total
        total_count.ballots_cast = row["total_ballots"]
        total_count.overvotes = row["total_over_votes"]
        total_count.undervotes = row["total_under_votes"]
        total_count_hash[total_count.object_id] = total_count        
        contest_total_counts[contest.id] ||= []
        contest_total_counts[contest.id] << total_count.object_id
      end
      total_count_by_gp_unit_id_absentee = "total-counts-#{ps.object_id}-#{contest_id}-#{Vedaspace::Enum::CountItemType.absentee.to_s}"
      if total_count_hash[total_count_by_gp_unit_id_absentee].nil?
        total_count = Vedastore::TotalCount.new        
        # absentee_ballots early_ballots	election_ballots        
        total_count.ballot_type = Vedastore::BallotType.absentee     
        total_count.gp_unit = ps.object_id
        total_count.object_id = total_count_by_gp_unit_id_absentee
        total_count.ballots_cast = row["absentee_ballots"]
        total_count.overvotes = row["absentee_over_votes"]
        total_count.undervotes = row["absentee_under_votes"]
        total_count_hash[total_count.object_id] = total_count        
        contest_total_counts[contest.id] ||= []
        contest_total_counts[contest.id] << total_count.object_id
      end
      
      total_count_by_gp_unit_id_early = "total-counts-#{ps.object_id}-#{contest_id}-#{Vedaspace::Enum::CountItemType.early.to_s}"
      if total_count_hash[total_count_by_gp_unit_id_early].nil?
        total_count = Vedastore::TotalCount.new        
        # absentee_ballots early_ballots	election_ballots        
        total_count.ballot_type = Vedaspace::Enum::CountItemType.early
        total_count.gp_unit = ps.object_id
        total_count.object_id = total_count_by_gp_unit_id_early
        total_count.ballots_cast = row["early_ballots"]
        total_count.overvotes = row["early_over_votes"]
        total_count.undervotes = row["early_under_votes"]
        total_count_hash[total_count.object_id] = total_count        
        contest_total_counts[contest.id] ||= []
        contest_total_counts[contest.id] << total_count.object_id
      end
      
      total_count_by_gp_unit_id_election_day = "total-counts-#{ps.object_id}-#{contest_id}-#{Vedaspace::Enum::CountItemType.election_day.to_s}"
      if total_count_hash[total_count_by_gp_unit_id_election_day].nil?
        total_count = Vedastore::TotalCount.new        
        # absentee_ballots early_ballots	election_ballots        
        total_count.ballot_type = Vedaspace::Enum::CountItemType.election_day
        total_count.gp_unit = ps.object_id
        total_count.object_id = total_count_by_gp_unit_id_election_day
        total_count.ballots_cast = row["election_ballots"]
        total_count.overvotes = row["election_over_votes"]
        total_count.undervotes = row["election_under_votes"]
        total_count_hash[total_count.object_id] = total_count        
        contest_total_counts[contest.id] ||= []
        contest_total_counts[contest.id] << total_count.object_id
      end
      
    end
    
    self.update_attributes(rows_processed: self.row_count)
    
    
    # break it down
    grp_size = 5000
    i = 0
    length = vc_list.size
    
    vc_list.in_groups_of(grp_size, false) do |group|
      Vedastore::VoteCount.import(group)
      puts "Imported Vote Counts #{i*grp_size}-#{(i+1)*grp_size} of #{length}"      
      i += 1
    end
    
    i = 0
    length = total_count_hash.values.size
    total_count_hash.values.in_groups_of(grp_size, false) do |group|
      Vedastore::TotalCount.import(group)
      puts "Imported Total Count #{i*grp_size}-#{(i+1)*grp_size} of #{length}"   
      i += 1  
    end
    
    puts "reload total_count list"
    h = {}
    i = 0
    length = total_count_hash.keys.size
    total_count_hash.keys.in_groups_of(grp_size, false) do |group|
      Vedastore::TotalCount.where(:object_id=>group).each do |tc|
        h[tc.object_id] = tc.id
      end
      puts "Reloading total_count list #{i*grp_size}-#{(i+1)*grp_size} of #{length}" 
      i += 1      
    end
    total_count_hash = h
    

    puts "Build Contest Total Counts by gpunit list"
    contest_total_counts_by_gp_unit = []
    contest_total_counts.each do |contest_id, tc_object_id_list|
      tc_object_id_list.each do |tc_object_id|
        contest_total_counts_by_gp_unit << Vedastore::ContestTotalCountsByGPUnit.new(total_count_id: total_count_hash[tc_object_id], contest_id: contest_id)
      end
    end
    
    i = 0
    length = contest_total_counts_by_gp_unit.size
    puts "Load #{length} total count by gp unit"
    contest_total_counts_by_gp_unit.in_groups_of(grp_size, false) do |group|
      Vedastore::ContestTotalCountsByGPUnit.import(group)
      puts "Imported Total Count by GPUnit #{i*grp_size}-#{(i+1)*grp_size} of #{length}"      
      i += 1
    end
    
    
    
    
    # TODO: when uploading results, change the report status. To what?
    
    puts "Save!"
    election_report.status = Vedastore::ReportStatus.unofficial_complete
    election_report.save!  
  end
  
end
