require 'nokogiri'

module Hart
  class Parser
    def self.parse(dest, report, include_results=false)
      source = report.election_report_upload.background_source

      Hart::Mapper.map(dest)      
      
      er = DMap::ModelRegister.classes[:election_report].all.values.first
    
      # build the election report
      jurisdiction = report.jurisdiction
      election = Vedastore::Election.new
      
      # general for now
      election.election_type = Vedaspace::Enum::ElectionType.general
      
      report.election = election
    
      #election.object_id = "election-#{er.name}"
      
      # TODO: build helper for internationalized text
      election.name = Vedastore::InternationalizedText.new
      election_name = Vedastore::LanguageString.new
      election_name.text = er.name
      election_name.language = 'en'
      election.name.language_strings << election_name
    
      report.issuer = er.locality
      report.issuer_abbreviation = er.state_abbreviation
      report.sequence_start = 0
      report.sequence_end = 0
      report.vendor_application_identifier = "OSET-VEDaPublisher-HART"
      report.format = er.format == 'Precinct' ? Vedaspace::Enum::ReportDetailLevel.precinct_level : Vedaspace::Enum::ReportDetailLevel.summary_contest
      
      # Hart data is always pre-election
      report.status = Vedaspace::Enum::ResultsStatus.pre_election    
    
      report.generated_date = DateTime.now.iso8601 #(Date.parse(er.date).iso8601)
      report.save!
    
      districts = {}
      source_districts = source.districts.inject({}) do |h, sd|
        h[sd.internal_id] = sd
        h
      end
      DMap::ModelRegister.classes[:district].all.values.each do |d|
        district = Vedastore::ReportingUnit.new
        district.is_districted = true

        # TODO: build helper for external ids
        local_geo_code = Vedastore::ExternalIdentifier.new 
        local_geo_code.label = 'internal_id'
        local_geo_code.identifier_type = Vedaspace::Enum::IdentifierType.other #.local_level ?
        local_geo_code.other_type = "HART internal ID"
        local_geo_code.value = d.id
        district.external_identifier_collection = Vedastore::ExternalIdentifierCollection.new
        district.external_identifier_collection.external_identifiers << local_geo_code
        
        district.name = d.attributes[:name]
        source_district = source_districts[d.id] #source.districts.where(internal_id: d.id).first
        if source_district.nil?
          raise "District #{d} not found in background data from source #{source}!"
        end
        
        district.object_id = source_district.object_id
        
        ocd_id = Vedastore::ExternalIdentifier.new 
        ocd_id.identifier_type = Vedaspace::Enum::IdentifierType.ocd_id
        ocd_id.value = source_district.ocd_id
        district.external_identifier_collection.external_identifiers << ocd_id
        
        district.reporting_unit_type = source_district.vedastore_district_type 
        
        # In this eleciton report, only the used sub-units should get added, 
        # so don't automatically add all of the source-district's reporting units. 
        # Do it according to the Hart election definition
        # source_district.reporting_units.each do |ru|
        #   district.gp_sub_unit_refs << Vssc::GPSubUnitRef.new(object_id: ru.object_id)
        # end
        
        district.election_report_id = report.id
        
        districts[district.object_id] = district
      end
      #bulk save and reload
      
      districts.values.each {|d| d.save! }
      # Vedastore::ReportingUnit.import(districts.values)
      # districts = Vedastore::ReportingUnit.where(object_id: districts.keys)
      
      
      
      
      # put all the precincts in with the related precinct-splits
      precincts = {}
      source_precincts = source.reporting_units.inject({}) do |h, ru|
        h[ru.internal_id] = ru
        h
      end
      DMap::ModelRegister.classes[:precinct].all.values.each do |p|
        precinct = Vedastore::ReportingUnit.new
        precinct.is_districted = false
        
        local_geo_code = Vedastore::ExternalIdentifier.new 
        local_geo_code.label = 'internal_id'
        local_geo_code.identifier_type = Vedaspace::Enum::IdentifierType.other #.local_level ?
        local_geo_code.other_type = "HART internal ID"
        local_geo_code.value = p.id
        precinct.external_identifier_collection = Vedastore::ExternalIdentifierCollection.new
        precinct.external_identifier_collection.external_identifiers << local_geo_code
        
        
        source_precinct = source_precincts[p.id] #source.reporting_units.where(:internal_id=>p.id).first
        if source_precinct.nil?
          raise "Precinct #{p} not found in source #{source}"
        end

        precinct.object_id = source_precinct.object_id
        
        ocd_id = Vedastore::ExternalIdentifier.new 
        ocd_id.identifier_type = Vedaspace::Enum::IdentifierType.ocd_id
        ocd_id.value = source_precinct.ocd_id
        precinct.external_identifier_collection.external_identifiers << ocd_id
        
        precinct.election_report_id = report.id
        
        precincts[precinct.object_id] = precinct
      end
      
      #Bulk import and reload precincts
      precincts.values.each {|p| p.save! }
      # Vedastore::ReportingUnit.import(precincts.values)
      # precincts = Vedastore::ReportingUnit.where(object_id: precincts.keys)

      report_gp_units = report.gp_units.where(type: "Vedastore::ReportingUnit", is_districted: false).inject({}) do |h, gpu|
        local_code = gpu.external_identifier_collection.external_identifiers.where(
          identifier_type: Vedaspace::Enum::IdentifierType.other.to_s
        ).first.value
        h[local_code] = gpu
        h
      end
      
      
      gp_sub_unit_refs = []
      precinct_splits = {}
      DMap::ModelRegister.classes[:precinct_split].all.values.each do |ps|
        precinct_split = Vedastore::GpUnit.new
        # precinct split has no background source equivalent??

        ocd_id = Vedastore::ExternalIdentifier.new 
        ocd_id.identifier_type = Vedaspace::Enum::IdentifierType.ocd_id
        ocd_id.value = "vspub-precinct-split-#{ps.id}"
        precinct_split.external_identifier_collection = Vedastore::ExternalIdentifierCollection.new
        precinct_split.external_identifier_collection.external_identifiers << ocd_id
        
        precinct = report_gp_units[ps.precinct_id] #report.gp_units.where(local_geo_code: ps.precinct_id, type: 'Vssc::ReportingUnit').first
        if precinct.nil?
          raise "Precinct #{ps.precinct_id} not found in source report"
        end
        
        gp_sub_unit_ref = Vedastore::GpUnitComposingGpUnitIdRef.new(composing_gp_unit_id_ref:  precinct_split.object_id, gp_unit_id: precinct.id)
        gp_sub_unit_refs << gp_sub_unit_ref
        
        precinct_split.election_report_id = report.id
        
        precinct_split.object_id = "vspub-precinct-split-#{ps.id}"
        
        precinct_splits[precinct_split.object_id] = precinct_split
      end

      precinct_splits.values.each {|ps| ps.save! }
      # Vedastore::GpUnit.import(precinct_splits.values)
      # precinct_splits = Vedastore::GpUnit.where(object_id: precinct_splits.keys)

      Vedastore::GpUnitComposingGpUnitIdRef.import(gp_sub_unit_refs)
      
      
      report_districts = report.gp_units.where(type: "Vedastore::ReportingUnit", is_districted: true).inject({}) do |h, d|
        local_code = d.external_identifier_collection.external_identifiers.where(
          identifier_type: Vedaspace::Enum::IdentifierType.other.to_s
        ).first.value
        h[local_code] = d
        h
      end
      district_sub_unit_refs = []

      DMap::ModelRegister.classes[:district_precinct_split].all.values.each do |d_ps|
        district = report_districts[d_ps.district_id] #report.gp_units.where(local_geo_code: d_ps.district_id, type: 'Vssc::District').first
        
        district_sub_unit_refs << Vedastore::GpUnitComposingGpUnitIdRef.new(composing_gp_unit_id_ref:  "vspub-precinct-split-#{d_ps.precinct_split_id}", gp_unit_id: district.id)
      end
      Vedastore::GpUnitComposingGpUnitIdRef.import(district_sub_unit_refs)
      
      DMap::ModelRegister.classes[:party].all.values.each do |p|
        party = Vedastore::Party.new
        party.abbreviation = p.abbreviation
        
        party.name = Vedastore::InternationalizedText.new
        party_name = Vedastore::LanguageString.new
        party_name.text = p.name
        party_name.language = 'en'
        party.name.language_strings << party_name
        
        # this may get overwritten later!! 
        party.object_id = "party-#{p.id}"
      
        report.parties << party
      end
      report.save!
      
      DMap::ModelRegister.classes[:candidate].all.values.each do |c|
        candidate = nil
        
        case c.relations(:contest).last.contest_type.downcase
        when 'c'
          candidate = Vedastore::Candidate.new
          candidate.object_id ="candidate-#{c.id}"
          candidate.party_identifier = "party-#{c.party_id}"
          
          
          candidate.ballot_name = Vedastore::InternationalizedText.new
          candidate_name = Vedastore::LanguageString.new
          candidate_name.text = c.name
          candidate_name.language = 'en'
          candidate.ballot_name.language_strings << candidate_name

          election.candidates << candidate
        when 'p'
        when 's'
        else 
          #nothing else
        end

      end
      report.save!
    
      DMap::ModelRegister.classes[:contest].all.values.each do |c|
        contest = nil
        if c.contest_type.downcase == "c"
          contest = Vedastore::CandidateContest.new
          
          
          contest.contest_office_id_refs << Vedastore::ContestOfficeIdRef.new({
            office_id_ref: "office-#{c.id}"            
          })
        
          office = Vedastore::Office.new
          office.object_id = "office-#{c.id}"

          office.name = Vedastore::InternationalizedText.new
          office_name = Vedastore::LanguageString.new
          office_name.text = c.office
          office_name.language = 'en'
          office.name.language_strings << office_name

          report.offices << office
        
        
          contest.number_elected = c.number_elected
          # For each candidate
          contest_gp_units = {}
          c.relations(:candidate).each_with_index do |candidate, i|
            candidate_selection = Vedastore::CandidateSelection.new
            candidate_selection.object_id = "candidate-selection-#{candidate.id}"
            candidate_selection.ballot_selection_candidate_id_refs << Vedastore::BallotSelectionCandidateIdRef.new({
              candidate_id_ref: "candidate-#{candidate.id}"
            })
            
            # Is this populated?
            candidate_selection.sequence_order = candidate.order
            
            contest.ballot_selections << candidate_selection
          end
        elsif c.contest_type.downcase == "p"
          contest = Vedastore::BallotMeasureContest.new

          contest.full_text = Vedastore::InternationalizedText.new
          contest_full_text = Vedastore::LanguageString.new
          contest_full_text.text = c.ballot_measure_title
          contest_full_text.language = 'en'
          contest.full_text.language_strings << contest_full_text


          c.relations(:candidate).each do |candidate|
            bm_selection = Vedastore::BallotMeasureSelection.new
            bm_selection.object_id ="ballot-measure-selection-#{candidate.id}"
            
            
            bm_selection.selection = Vedastore::InternationalizedText.new
            bm_selection_selection = Vedastore::LanguageString.new
            bm_selection_selection.text = candidate.name
            bm_selection_selection.language = 'en'
            bm_selection.selection.language_strings << bm_selection_selection
            
            contest.ballot_selections << bm_selection
          end
        elsif c.contest_type.downcase == "s"
          contest = Vedastore::PartyContest.new
          c.relations(:candidate).each do |candidate|
            party = report.parties.where(object_id: "party-#{candidate.party_id}").first
            party_selection = Vedastore::PartySelection.new
            if party.nil?
              raise "Party #{candidate.party_id} not found! (#{candidate.inspect})"
            end
            
            party_selection.ballot_selection_party_id_refs 
            
            # this is the only place the party "id" is defined (as used by the exported results) ?
            # party.local_party_code = "party-selection-#{candidate.id}" (?)
            # party.save!
            
            party_selection.object_id = "party-selection-#{candidate.id}"
            party_selection.ballot_selection_party_id_refs << 
            Vedastore::BallotSelectionPartyIdRef.new({
              ballot_selection: party_selection,
              party_id_ref: "party-#{candidate.party_id}"
            })
            contest.ballot_selections << party_selection
          end
          
          # Straight Party        
        else
          # Don't record generic ballot text
          next
        end
      
        # For whatever the contest, look at all the precinct-splits in the contest/precinct-split
        # and detect an exatly-matching district
        district_id = c.relations(:district_contest).last.district_id
        contest.electoral_district_identifier = source.districts.where(internal_id: district_id).first.object_id

        contest.object_id = "contest-#{c.id}"
        contest.name = c.office
        contest.sequence_order = c.order
        #:order, :id, :office, :contest_type, :instruction_text, :ballot_measure_title
      
        election.contests << contest
      end
    
      puts report.valid?
      puts report.errors.messages.collect{|k,v|"#{k}: #{v}"}.join("\n")
      
      return report
      
    end
  end
end
