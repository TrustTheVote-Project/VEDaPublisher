class ReportingUnit < ActiveRecord::Base
  
  belongs_to :jurisdiction
  belongs_to :background_source
  belongs_to :ocd_object
  delegate :ocd_id, to: :ocd_object

  has_and_belongs_to_many :districts
  
  def object_id
    "vspub-reporting-unit-#{self.id}"
  end
  
end