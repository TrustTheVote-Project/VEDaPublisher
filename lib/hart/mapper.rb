module Hart
  class Mapper
    
    # headers: travis is false, Orange county is true
    DEFAULTS={:format=>:tdf, :headers=>false}

    def self.map(file_base)    
      defaults = DEFAULTS.dup
      defaults = defaults.merge({:path=>file_base})
      DMap::File.define("ELECTION.txt", defaults) do |df|
        df.election_report :name, :locality, :election_type, :date, :state_abbreviation, 
                           :unknown?, :unknown?, :unknown?, :unknown?, :unknown?, :unknown?, :format
      end

      DMap::File.define("PARTY.txt", defaults) do |df|
        df.party :abbreviation, :name, :id
      end
    
    
      DMap::File.define("CONTEST.txt", defaults) do |df|
        df.contest :id, :order, :office, :contest_type, :instruction_text, :ballot_measure_title,
                   :unknown?, :unknown?, :number_elected
      end

      DMap::File.define("CANDIDATE.txt", defaults) do |df|
        df.candidate({:contest_id=>[:contest, :id]}, :id, :order, :party_abbr, :name, :unknown?, {:party_id=>[:party, :id]})
      end
    
      # Travis with precinct splits
      DMap::File.define("PRECINCT.txt", defaults) do |df|
          df.precinct_split :id, :order, {:precinct_id=>[:precinct, :id]}, :precinct_split_type, :unknown?
          df.precinct(:NA, :NA, :id, :NA, :NA)
      end

      # Orange County
      # DMap::File.define("PRECINCT.txt", defaults) do |df|
      #   df.precinct(:id, :order, :name, :split_name, :voters, :party_code, :rotation_index)
      # end

      
      DMap::File.define("DISTRICT.txt", defaults) do |df|
        df.district :id, :name
      end
    
      DMap::File.define_relation("PRECINCT_AND_DISTRICT.txt", defaults) do |df|
        df.district_precinct_split({:district_id=>[:district, :id]}, {:precinct_split_id=>[:precinct_split, :id]})
      end
    
      DMap::File.define("POLLING_PLACE.txt", defaults) do |df|
        df.polling_place :id, :name, :short_name
      end
    
      DMap::File.define("CONTEST.txt", defaults) do |df|
        df.hart_contest :id, :order, :name, :type, :instructions, :description
      end

      # DMap::File.define_relation("CONTEST_AND_PRECINCT.txt", DEFAULTS) do |df|
      #   df.contest_precinct_split({:contest_id=>[:contest, :id]}, {:precinct_split_id=>[:precinct_split, :id]})
      # end

      DMap::File.define_relation("DISTRICT_AND_CONTEST.txt", defaults) do |df|
        df.district_contest({:district_id=>[:district, :id]}, {:contest_id=>[:contest, :id]})
      end

      # DMap::File.define_relation('POLLING_PLACE_AND_PRECINCT.txt', DEFAULTS) do |df|
      #   df.polling_place_precinct({:polling_place_id=>[:polling_place, :id]},
      #     :polling_place_type, {:precinct_split_id=>[:precinct_split, :id]})
      # end

    end
            
  end
end