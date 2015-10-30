class Vedastore::GPUnit < ActiveRecord::Base
  has_one :ocd_object, foreign_key: :ocd_id, primary_key: :national_geo_code
  
  def to_xml_node_with_shapes(xml = nil, node_name = nil)
    if self.national_geo_code && ocd_object
      shape = ocd_object.shapes.last
      shape_data = shape ? shape.shape_data : nil
      if shape_data
        return to_xml_node_without_shapes(xml, node_name) do |xml|
          xml.send("SpatialDimension") do |sd|
            sd.send("SpatialExtent") do |se|
              se.send("Coordinates") do |coo|
                coo.cdata(shape_data)
              end
            end
          end
        end
      end
    end
    return to_xml_node_without_shapes(xml, node_name)
  end
  
  alias_method_chain :to_xml_node, :shapes
  
  
  
end
