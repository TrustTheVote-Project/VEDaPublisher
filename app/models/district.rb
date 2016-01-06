class District < ActiveRecord::Base
  
  belongs_to :jursidiction
  belongs_to :background_source
  
  belongs_to :ocd_object
  delegate :ocd_id, to: :ocd_object
  
  has_and_belongs_to_many :reporting_units
  
  def object_id
    "vspub-district-#{self.id}"
  end
  
  def vedastore_district_type
    t = Vedaspace::Enum::ReportingUnitType.find(self.district_type) 
    
    t = t || case self.district_type
    when "School District"
      Vedaspace::Enum::ReportingUnitType.school
    when "Aquifer District", "WCID", "Water District"
      Vedaspace::Enum::ReportingUnitType.water
    when "Municipal Utility District", "MUD"
      Vedaspace::Enum::ReportingUnitType.utility
    when "Community College", "Library District"
      Vedaspace::Enum::ReportingUnitType.other
    when "State House"
      Vedaspace::Enum::ReportingUnitType.state_house
    when "State Senate"
      Vedaspace::Enum::ReportingUnitType.state_senate
    when "Federal", "Federal Ballot", "All", "Statewide"
      Vedaspace::Enum::ReportingUnitType.state
    else
      Vedaspace::Enum::ReportingUnitType.other
    end
    
    return t
  
  end
  
  # def vssc_type
  #   case self.district_type
  #   when "Congressional"
  #     Vssc::DistrictType.congressional
  #   when "City", "Community College", "School District", "Aquifer District", "Library District",  "Municipal Utility District", "MUD", "WCID", "Water District",
  #     Vssc::DistrictType.local
  #   when "County"
  #     Vssc::DistrictType.locality
  #   when "State House"
  #     Vssc::DistrictType.state_house
  #   when "State Senate"
  #     Vssc::DistrictType.state_senate
  #   when "Federal", "Federal Ballot", "All", "Statewide"
  #     Vssc::DistrictType.statewide
  #   else
  #     Vssc::DistrictType.other
  #   end
  # end
  
end
