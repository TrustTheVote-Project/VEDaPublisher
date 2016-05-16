class ShapeSource < ActiveRecord::Base
  
  belongs_to :background_source
  has_many :shapes
  
  def load_reporting_units_from_kml(kml_file)
    doc = Nokogiri::XML(kml_file.read) { |config| config.noblanks }
    doc.css("Placemark").each do |p|
      pct_id = p.css("SimpleData[name='PCT']").text()
      shape_data = p.css("Polygon").to_s
      pct = background_source.reporting_units.find_by_internal_id(pct_id)
      if pct.nil?
        next
        raise pct_id.to_s
        
      end
      self.shapes.build(ocd_object: pct.ocd_object, internal_id: pct_id, shape_data: shape_data, shape_type: "KML")
    end
    save!
  end
  
end
