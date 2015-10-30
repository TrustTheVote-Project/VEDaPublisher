require 'csv'
class Vedastore::ElectionReport < ActiveRecord::Base
  def self.find_with_eager_load(id)
    e = self.where(id: id).includes([
      {:gp_units=>[
          :reporting_unit_authority_refs,
          :contacts,
          :gp_sub_units, 
          :gp_sub_unit_refs, 
          :total_counts, 
          :party_registration,
          {:spatial_dimensions=>[:spatial_extent]},
          {:ocd_object=>[:shapes]}
        ]},
      :ballot_selections,
      {:people=>[
        {:contacts=>[:reporting_units]}
      ]},
      :offices,
      {:elections=>[
          {:ballot_styles=>[:ordered_contests]},
          {:candidates=>[:offices]},
          {:contests=>[
            {:ballot_selections=>[
                #:counts,
                {:candidate_selection_candidate_refs=>[:candidate]}
              ]},
            {:contest_total_counts=>[:total_count]},
            :total_counts_by_gp_unit
          ]}
        ]
      }
    ]).first
    
    #load all counts
    ballot_selection_ids = []
    e.elections.each do |election|
      election.contests.each do |contest|
        puts "Loading contest #{contest.inspect} ballot selections"
        Rails.logger.debug("Loading contest #{contest.inspect} ballot selections")
        ballot_selection_ids << contest.ballot_selections.collect(&:id)
      end
    end

    # puts ballot_selection_ids.count
    #
    
    batch_size = 10000
    
    count = Vssc::Count.where(:ballot_selection_id=>ballot_selection_ids).count
    puts count
    Rails.logger.debug("#{count} Counts")
    
    ballot_selection_counts = {}
    
    Vssc::Count.where(:ballot_selection_id=>ballot_selection_ids).find_in_batches(batch_size: batch_size).with_index do |group, batch|
      puts "Loading #{batch * batch_size} of #{count}"
      Rails.logger.debug("Loading #{batch * batch_size} of #{count}")
      group.each do |vc|
        ballot_selection_counts[vc.ballot_selection_id] ||= []
        ballot_selection_counts[vc.ballot_selection_id] << vc        
      end
    end

    e.elections.each do |election|
      election.contests.each do |contest|
        puts "Substituting contest #{contest.inspect} ballot selections"
        Rails.logger.debug("Substituting contest #{contest.inspect} ballot selections")
        contest.ballot_selections.each do |bs|
          records = ballot_selection_counts[bs.id] || []
          association = bs.association(:counts)
          association.loaded!
          association.target.concat(records.to_a)
          records.each { |record| association.set_inverse_instance(record) }
        end
      end
    end
    
    return e
    
  end

  has_one :election_report_upload, dependent: :destroy
  delegate :jurisdiction, to: :election_report_upload
  
  def parse_hart_dir(dest)
    Hart::Parser.parse(dest, self)
  end
  
  attr_reader :election_results_csv
  
  def election_results_csv=(file)
    eru = ElectionResultUpload.create(election_report: self, file: file)
    eru.delay.process!
  end
  
  
  
  def self.from_jurisdiction(j)
    er = self.new
    er.object_id = "VSPubJurisdictionReport-#{j.id}-#{DateTime.now}"
    er.date = DateTime.now
    er.format = Vssc::ReportFormat.summary_contest
    er.status = Vssc::ReportFormat.pre_election
    er.issuer = "VSPub-#{j.name}"
    er.state_abbreviation = j.state_abbreviation
    er.vendor_application_id = "VSPub-<some-deployment-specific-guid>"
    
    j.districts.each do |d|
      district = Vssc::District.new
      district.district_type = d.vssc_district_type
      
      d.reporting_units.each do |ru|
        district.gp_sub_unit_refs << Vssc::GPSubUnitRef.new(object_id: ru.object_id)
      end
      
      district.object_id = d.object_id
      district.local_geo_code = d.internal_id
      district.name = d.name
      district.national_geo_code = d.ocd_id
      
      er.gp_units << district
    end
    
    j.reporting_units.each do |ru|
      reporting_unit = Vssc::ReportingUnit.new

      reporting_unit.object_id = ru.object_id
      reporting_unit.local_geo_code = ru.internal_id
      reporting_unit.name = ru.name
      reporting_unit.national_geo_code = ru.ocd_id
      
      reporting_unit.reporting_unit_type = Vssc::ReportingUnitType.precinct      
      
      er.gp_units << reporting_unit      
    end
    return er
  end
  
end
