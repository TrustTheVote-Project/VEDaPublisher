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
  
    election = Vedastore::Election.where(id: election_report.election_id).includes([
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
        parties: c.ballot_selections.inject({}){|bsr, bs| bsr[bs.object_id]=bs if bs.is_a?(Vedastore::PartySelection); bsr},
        write_ins: {}
      }
      r
    end
  
    vc_list = []
    new_contests = {}
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
      contest_info = contests["contest-#{contest_id}"]
      if !(contest_info)
        contest_type = Vedastore::CandidateContest  
        if row['Contest_Type'] == 'B' 
          contest_type = Vedastore::BallotMeasureContest
        elsif row['Contest_Type'] == 'P'
          contest_type = Vedastore::PartyContest
        end
        contest = contest_type.new
        contest.election_id = election.id
        contest.name = row['Contest_title']
        contest.save!
        
        contest_info = {
          contest: contest,
          ballot_selections: {},
          parties: {},
          write_ins: {}
        }
        contests["contest-#{contest_id}"] = contest_info
        
        new_contests["contest-#{contest_id}"] = {
          contest: contest,
          precincts: {}
        }
      else
        contest = contest_info[:contest]
      end
      
      if new_contests["contest-#{contest_id}"]
        pct_id = row['Precinct_name']
        if new_contests["contest-#{contest_id}"][:precincts][pct_id].nil?
          new_contests["contest-#{contest_id}"][:precincts][pct_id] = {
            id: pct_id,
            name: row['Precinct_name']
          }
        end
      end
    
    
    
      candidate_id = row['candidate_id']
      candidate_type = row["Candidate_Type"].to_s.downcase # C vs W for write-in
      candidate_selection = nil
      if contest.is_a?(Vedastore::CandidateContest)
        if candidate_type == "c"
          candidate_selection = contest_info[:ballot_selections]["candidate-selection-#{candidate_id}"]
        end
        if candidate_selection.nil? || candidate_type == "w"
          #Add a write-in option
          selection_id = nil
          if candidate_type == "w"
            selection_id = "candidate-selection-writein-#{candidate_id}"
            #see if it's already added
            candidate_selection = contest_info[:write_ins][selection_id]
          else
            selection_id = "candidate-selection-#{candidate_id}"
          end
          if candidate_selection.nil?
            candidate_selection= Vedastore::CandidateSelection.new
            candidate_selection.is_write_in = candidate_type == "w"
            candidate_selection.object_id = selection_id
            candidate_id = candidate_selection.is_write_in ? "candidate-writein-#{candidate_id}" : "candidate-#{candidate_id}"
            candidate_selection.ballot_selection_candidate_id_refs << Vedastore::BallotSelectionCandidateIdRef.new(
              candidate_id_ref: candidate_id
            )
          
            new_candidate = Vedastore::Candidate.new(object_id: candidate_id)            
            new_candidate.ballot_name = Vedastore::InternationalizedText.new
            candidate_name = Vedastore::LanguageString.new
            candidate_name.text = row["candidate_name"]
            candidate_name.language = 'en'
            new_candidate.ballot_name.language_strings << candidate_name
          
            election.candidates << new_candidate
          
            election.save!
            contest.ballot_selections << candidate_selection
            contest.save!
            if candidate_selection.is_write_in
              contest_info[:write_ins][selection_id] = candidate_selection
            else
              contest_info[:ballot_selections][selection_id] = candidate_selection
            end
          end
        end
      elsif contest.is_a?(Vedastore::PartyContest)
        candidate_selection = contest_info[:parties]["party-selection-#{candidate_id}"]
        if candidate_selection.nil?
          candidate_selection = Vedastore::PartySelection.new
          candidate_selection.object_id = "party-selection-#{candidate_id}"
          party_id = "party-#{candidate_id}"
          candidate_selection.ballot_selection_party_id_refs << Vedastore::BallotSelectionPartyIdRef.new(
            party_id_ref: party_id
          )
          new_party = election_report.parties.find_or_create_by(object_id: party_id)
          new_party.abbreviation ||= row['Party_Code']
          new_party.save!
          candidate_selection.save!
          contest.ballot_selections << candidate_selection
          contest.save!
          contest_info[:parties]["party-selection-#{candidate_id}"] = candidate_selection
        end
        # contest.ballot_selections.where(local_party_code: "party-selection-#{candidate_id}").first
      elsif contest.is_a?(Vedastore::BallotMeasureContest)
        bms_id = "ballot-measure-selection-#{candidate_id}"
        candidate_selection = contest_info[:ballot_selections][bms_id]
        if candidate_selection.nil?
          candidate_selection = Vedastore::BallotMeasureSelection.new
          candidate_selection.object_id = bms_id
          
          selection_name = Vedastore::LanguageString.new
          selection_name.text = row["candidate_name"]
          selection_name.language = 'en'
          candidate_selection.selection = Vedastore::InternationalizedText.new
          candidate_selection.selection.language_strings << selection_name
          
          candidate_selection.save!
          contest.ballot_selections << candidate_selection
          contest.save!
          contest_info[:ballot_selections][bms_id] = candidate_selection
          
        end
      end
      if candidate_selection.nil?
        raise "No candidate selection for contest #{contest.type} #{contest.id}, candidate #{candidate_id}"
      end

      # find the precinct split with this ID

      gp_unit_pct_id = row["Pct_Id"].to_s

      ps = gp_units["vspub-precinct-split-#{gp_unit_pct_id}"]
      if ps.nil?
        ps = gp_units["vspub-reporting-unit-#{gp_unit_pct_id}"] || gp_units["vspub-precinct-#{gp_unit_pct_id}"]
      end
      if ps.is_a?(Vedastore::ReportingUnit) && row["Reg_voters"].to_i > 0 && ps.voters_registered.to_i != row["Reg_voters"].to_i
        ps.update_attributes(voters_registered: row["Reg_voters"].to_i)
      end
      ccp = "#{contest_id}-#{candidate_id}-#{gp_unit_pct_id}"
      
      if ps.nil?
        raise gp_unit_pct_id.to_s + "\n\n" + gp_units.keys.join("\n")
      end
  
      vc_a = Vedastore::VoteCount.new
      vc_e = Vedastore::VoteCount.new
      vc = Vedastore::VoteCount.new
    
      vc_e.gp_unit_identifier = vc.gp_unit_identifier = vc_a.gp_unit_identifier = ps.object_id
      #vc_a.object_id = "votecount-#{ccp}-absentee"
      vc_a.count_item_type = Vedaspace::Enum::CountItemType.absentee
      vc_a.count = row["absentee_votes"]
      #vc_e.object_id = "votecount-#{ccp}-early"
      vc_e.count_item_type = Vedaspace::Enum::CountItemType.early
      vc_e.count = row["early_votes"]
      #vc.object_id = "votecount-#{ccp}-election-day"
      vc.count_item_type = Vedaspace::Enum::CountItemType.election_day
      vc.count = row["election_votes"]
    
      vc.countable_id = candidate_selection.id
      vc.countable_type = Vedastore::BallotSelection
      vc_a.countable_id = candidate_selection.id
      vc_a.countable_type = Vedastore::BallotSelection
      vc_e.countable_id = candidate_selection.id
      vc_e.countable_type = Vedastore::BallotSelection
    
      vc_list << vc
      vc_list << vc_a
      vc_list << vc_e
    
    
      total_count_by_gp_unit_id_total = "total-counts-#{ps.object_id}-#{contest_id}-#{Vedaspace::Enum::CountItemType.total.to_s}"
      if total_count_hash[total_count_by_gp_unit_id_total].nil?
        total_count = Vedastore::SummaryCount.new        
        # absentee_ballots early_ballots	election_ballots        
        total_count.count_item_type = Vedaspace::Enum::CountItemType.total     
        total_count.gp_unit_identifier = ps.object_id
        # total_count.object_id = total_count_by_gp_unit_id_total
        total_count.ballots_cast = row["total_ballots"]
        total_count.overvotes = row["total_over_votes"]
        total_count.undervotes = row["total_under_votes"]
        total_count_hash[total_count_by_gp_unit_id_total] = total_count        
        contest_total_counts[contest.id] ||= []
        contest_total_counts[contest.id] << total_count
      end
    
      total_count_by_gp_unit_id_absentee = "total-counts-#{ps.object_id}-#{contest_id}-#{Vedaspace::Enum::CountItemType.absentee.to_s}"
      if total_count_hash[total_count_by_gp_unit_id_absentee].nil?
        total_count = Vedastore::SummaryCount.new        
        # absentee_ballots early_ballots	election_ballots        
        total_count.count_item_type = Vedaspace::Enum::CountItemType.absentee     
        total_count.gp_unit_identifier = ps.object_id
        # total_count.object_id = total_count_by_gp_unit_id_absentee
        total_count.ballots_cast = row["absentee_ballots"]
        total_count.overvotes = row["absentee_over_votes"]
        total_count.undervotes = row["absentee_under_votes"]
        total_count_hash[total_count_by_gp_unit_id_absentee] = total_count        
        contest_total_counts[contest.id] ||= []
        contest_total_counts[contest.id] << total_count
      end
    
      total_count_by_gp_unit_id_early = "total-counts-#{ps.object_id}-#{contest_id}-#{Vedaspace::Enum::CountItemType.early.to_s}"
      if total_count_hash[total_count_by_gp_unit_id_early].nil?
        total_count = Vedastore::SummaryCount.new        
        # absentee_ballots early_ballots	election_ballots        
        total_count.count_item_type = Vedaspace::Enum::CountItemType.early
        total_count.gp_unit_identifier = ps.object_id
        # total_count.object_id = total_count_by_gp_unit_id_early
        total_count.ballots_cast = row["early_ballots"]
        total_count.overvotes = row["early_over_votes"]
        total_count.undervotes = row["early_under_votes"]
        total_count_hash[total_count_by_gp_unit_id_early] = total_count        
        contest_total_counts[contest.id] ||= []
        contest_total_counts[contest.id] << total_count
      end
    
      total_count_by_gp_unit_id_election_day = "total-counts-#{ps.object_id}-#{contest_id}-#{Vedaspace::Enum::CountItemType.election_day.to_s}"
      if total_count_hash[total_count_by_gp_unit_id_election_day].nil?
        total_count = Vedastore::SummaryCount.new        
        # absentee_ballots early_ballots	election_ballots        
        total_count.count_item_type = Vedaspace::Enum::CountItemType.election_day
        total_count.gp_unit_identifier = ps.object_id
        # total_count.object_id = total_count_by_gp_unit_id_election_day
        total_count.ballots_cast = row["election_ballots"]
        total_count.overvotes = row["election_over_votes"]
        total_count.undervotes = row["election_under_votes"]
        total_count_hash[total_count_by_gp_unit_id_election_day] = total_count        
        contest_total_counts[contest.id] ||= []
        contest_total_counts[contest.id] << total_count
      end
    
    end
  
    self.update_attributes(rows_processed: self.row_count)
  
    # any newly defined contests should get saved
    new_contests.each do |o_id, contest_precincts|
      contest = contest_precincts[:contest]
      
      # begin
      #   contest.electoral_district_id = election_report.district_from_precinct_ids(
      #     contest_precincts[:precincts].collect {|pct_id, pct_info| "#{pct_info[:name]}" }
      #   ).object_id
      # rescue Exception => e
      #   raise "\n" + "#{contest.id} #{contest.name}" + e.message.to_s
      # end
      
      
      # Also add all precincts and this district to the list of election_report gp_units??
      
      
      contest.save!
    end
  
  
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
    total_count_imported = []
    total_count_hash.values.in_groups_of(grp_size, false) do |group|
      Vedastore::SummaryCount.import(group)
      total_count_imported += Vedastore::SummaryCount.pluck(:id).last(group.size)
      puts "Imported Total Count #{i*grp_size}-#{(i+1)*grp_size} of #{length}"
      i += 1  
    end
  
    puts "reload total_count list"
    h = {}
    i = 0
    length = total_count_hash.keys.size
    total_count_imported.in_groups_of(grp_size, false) do |group|
      Vedastore::SummaryCount.where(id: group).each do |tc|
        h[tc.object_id] = tc.id
      end
      puts "Reloading total_count list #{i*grp_size}-#{(i+1)*grp_size} of #{length}" 
      i += 1      
    end
    total_count_hash = h
  
    # Vedastore::Contest has Summary Counts (summary_counts) 
    #
    puts "Build Contest Total Counts by gpunit list"
    contest_total_counts_by_gp_unit = []
    contest_total_counts.each do |contest_id, tc_list|
      tc_list.each do |tc|
        sc = Vedastore::SummaryCount.new
        sc.count_item_type = tc.count_item_type
        sc.gp_unit_identifier = tc.gp_unit_identifier
        sc.ballots_cast = tc.ballots_cast
        sc.overvotes = tc.overvotes
        sc.undervotes = tc.undervotes
      
        sc.countable_type = Vedastore::Contest
        sc.countable_id = contest_id
      
        contest_total_counts_by_gp_unit << sc
      end
    end

    i = 0
    length = contest_total_counts_by_gp_unit.size
    puts "Load #{length} total count by gp unit"
    contest_total_counts_by_gp_unit.in_groups_of(grp_size, false) do |group|
      Vedastore::SummaryCount.import(group)
      puts "Imported Total Count by GPUnit #{i*grp_size}-#{(i+1)*grp_size} of #{length}"
      i += 1
    end
  
  
  
    # TODO: when uploading results, change the report status. To what?
  
    puts "Save!"
    election_report.status = Vedaspace::Enum::ResultsStatus.unofficial_complete
    election_report.save!  

  end
  
end
