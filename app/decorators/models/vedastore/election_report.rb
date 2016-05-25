require 'csv'
Vedastore::ElectionReport.class_eval do
  def self.find_with_eager_load(id)
    e = self.where(id: id).includes([
      {:gp_units=>[
          :gp_unit_composing_gp_unit_id_refs,
          :external_identifier_collection,
          #:contacts,
          #:gp_sub_units, 
          #:gp_sub_unit_refs, 
          #:total_counts, 
          :summary_counts,
          #:party_registration,
          #{:spatial_dimensions=>[:spatial_extent]},
          #{:ocd_object=>[:shapes]}
        ]},
      #:ballot_selections,
      {:parties=>[{:name=>[:language_strings]}]},
      {:people=>[{:full_name=>[:language_strings]}, {:profession=>[:language_strings]}, {:title=>[:language_strings]}]},
      {:offices=>[{:name=>[:language_strings]}]},
      {:people=>[
        {:contacts=>[:reporting_units]}
      ]},
      {:election=>[
          {:name=>[:language_strings]},
          {:ballot_styles=>[:ordered_contests]},
          {:candidates=>[:external_identifier_collection, {:ballot_name=>[:language_strings]}]},
          {:contests=>[
            {:ballot_selections=>[
                #:counts,
                #{:candidate_selection_candidate_refs=>[:candidate]}
              ]},
            {:ballot_title=>[:language_strings]},
            {:ballot_sub_title=>[:language_strings]},
            :external_identifier_collection,
            :summary_counts,
            #{:contest_total_counts=>[:total_count]},
            #:total_counts_by_gp_unit
          ]}
        ]
      }
    ]).first
    
    Rails.logger.info "Loaded Election Report"
    
    #load all counts
    ballot_selection_ids = []
    e.election.tap do |election|
      election.contests.each do |contest|
        Rails.logger.info "Loading contest #{contest.inspect} ballot selections"
        ballot_selection_ids << contest.ballot_selections.collect(&:id)
        
        
        
      end
    end
    
    
    ballot_selection_ids = ballot_selection_ids.flatten


    batch_size = 10000
    
    count = Vedastore::VoteCount.where(:countable_id=>ballot_selection_ids, :countable_type=>Vedastore::BallotSelection).count
    Rails.logger.info("#{count} Counts")
    
    ballot_selection_counts = {}
    
    Vedastore::VoteCount.where(:countable_id=>ballot_selection_ids, :countable_type=>Vedastore::BallotSelection).find_in_batches(batch_size: batch_size).with_index do |group, batch|
      Rails.logger.info("Loading #{batch * batch_size} of #{count}")
      group.each do |vc|
        ballot_selection_counts[vc.countable_id] ||= []
        ballot_selection_counts[vc.countable_id] << vc        
      end
    end
    
    ballot_selection_candidate_id_refs = {}
    Vedastore::BallotSelectionCandidateIdRef.where(ballot_selection_id: ballot_selection_ids).find_in_batches(batch_size: batch_size).with_index do |group, batch|
      Rails.logger.info("Loading #{batch * batch_size} of #{count}")
      group.each do |cid_ref|
        ballot_selection_candidate_id_refs[cid_ref.ballot_selection_id] ||= []
        ballot_selection_candidate_id_refs[cid_ref.ballot_selection_id] << cid_ref        
      end
      
    end
    #:ballot_selection_candidate_id_refs,
    
    ballot_selection_endorsement_party_id_refs = {}
    Vedastore::BallotSelectionCandidateIdRef.where(ballot_selection_id: ballot_selection_ids).find_in_batches(batch_size: batch_size).with_index do |group, batch|
      Rails.logger.info("Loading #{batch * batch_size} of #{count}")
      group.each do |cid_ref|
        ballot_selection_candidate_id_refs[cid_ref.ballot_selection_id] ||= []
        ballot_selection_candidate_id_refs[cid_ref.ballot_selection_id] << cid_ref        
      end
      
    end
    #:ballot_selection_endorsement_party_id_refs
    
    

    e.election.tap do |election|
      election.contests.each do |contest|
        Rails.logger.info("Substituting contest #{contest.inspect} ballot selections")
        contest.ballot_selections.each do |bs|
          count_records = ballot_selection_counts[bs.id] || []
          association = bs.association(:counts)
          association.loaded!
          association.target.concat(count_records.to_a)
          count_records.each { |record| association.set_inverse_instance(record) }

          # Build ballot selection associations
          cid_ref_records = ballot_selection_candidate_id_refs[bs.id] || []
          if cid_ref_records.any?
            association = bs.association(:ballot_selection_candidate_id_refs)
            association.loaded!
            association.target.concat(cid_ref_records.to_a)
            cid_ref_records.each { |record| association.set_inverse_instance(record) }
          end
          
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
  
  def to_xml
    self.to_xml_node #.to_xml
  end
  
  def write_file
    loaded_report = self.class.find_with_eager_load(self.id)
    fname = "election_report_#{id}.xml"
    File.open(fname, "w+") do |f|
      f.write loaded_report.to_xml
    end
    puts "wrote #{fname}"
  end
    
  
  attr_reader :election_results_csv
  
  def election_results_csv=(file)
    eru = ElectionResultUpload.create(election_report: self, file: file)
    eru.delay.process!
  end
  
  def district_from_precinct_ids(id_list)
    @districts ||= self.get_districts_and_sub_gp_unit_list
    id_key = id_list.collect(&:to_s).sort
    district = @districts[id_key]
    raise id_key.join(", ") + "\n\n" + @districts.keys.collect {|k| k.join(", ") }.join("\n\n") if district.nil?
    return district
  end
  
  def get_districts_and_sub_gp_unit_list
    dist_id_keys = {}
    jurisdiction.districts.each do |d|
      id_list = d.reporting_units.collect(&:internal_id)
      id_key = id_list.collect(&:to_s).sort
      dist_id_keys[id_key] = d
    end
    return dist_id_keys
  end
  
  
  def self.from_jurisdiction(j)
    er = self.new
    #er.object_id = "VSPubJurisdictionReport-#{j.id}-#{DateTime.now}"
    er.generated_date = DateTime.now
    er.format = Vedaspace::Enum::ReportDetailLevel.summary_contest
    er.status = Vedaspace::Enum::ResultsStatus.pre_election
    er.issuer = "VSPub-#{j.name}"
    er.issuer_abbreviation = j.state_abbreviation
    er.vendor_application_identifier = "VSPub-<some-deployment-specific-guid>"
    
    j.districts.each do |d|
      district = Vedastore::ReportingUnit.new(is_districted: true)
      district.reporting_unit_type = d.vedastore_district_type
      
      d.reporting_units.each do |ru|
        district.gp_unit_composing_gp_unit_id_refs << Vedastore::GpUnitComposingGpUnitIdRef.new(composing_gp_unit_id_ref: ru.object_id)
      end
      
      district.object_id = d.object_id
      
      district.build_external_identifier_collection
      district.external_identifier_collection.external_identifiers << Vedastore::ExternalIdentifier.new({
        value: d.internal_id,
        identifier_type: Vedaspace::Enum::IdentifierType.local_level
      })
      
      district.name = d.name
      district.external_identifier_collection.external_identifiers << Vedastore::ExternalIdentifier.new({
        value: d.ocd_id,
        identifier_type: Vedaspace::Enum::IdentifierType.ocd_id
      })
      
      er.gp_units << district
    end
    
    j.reporting_units.each do |ru|
      reporting_unit = Vedastore::ReportingUnit.new

      reporting_unit.object_id = ru.object_id
      reporting_unit.build_external_identifier_collection
      reporting_unit.external_identifier_collection.external_identifiers << Vedastore::ExternalIdentifier.new({
        value: ru.internal_id,
        identifier_type: Vedaspace::Enum::IdentifierType.local_level
      })
      
      reporting_unit.name = ru.name
      reporting_unit.external_identifier_collection.external_identifiers << Vedastore::ExternalIdentifier.new({
        value: ru.ocd_id,
        identifier_type: Vedaspace::Enum::IdentifierType.ocd_id
      })
      
      reporting_unit.reporting_unit_type = Vedaspace::Enum::ReportingUnitType.precinct      
      
      er.gp_units << reporting_unit      
    end
    return er
  end
  
end
