# class Vedastore::GpUnit < ActiveRecord::Base
#   has_one :ocd_object, foreign_key: :ocd_id, primary_key: :national_geo_code
#
#   def to_xml_node_with_shapes(xml = nil, node_name = nil)
#     if self.national_geo_code && ocd_object
#       shape = ocd_object.shapes.last
#       shape_data = shape ? shape.shape_data : nil
#       if shape_data
#         return to_xml_node_without_shapes(xml, node_name) do |xml|
#           xml.send("SpatialDimension") do |sd|
#             sd.send("SpatialExtent") do |se|
#               se.send("Coordinates") do |coo|
#                 coo.cdata(shape_data)
#               end
#             end
#           end
#         end
#       end
#     end
#     return to_xml_node_without_shapes(xml, node_name)
#   end
#
#   alias_method_chain :to_xml_node, :shapes
#
#
#
# end
Vedastore::GpUnit.class_eval do
  has_one :ocd_object, foreign_key: :ocd_id, primary_key: :national_geo_code

  def national_geo_code
    ngc = self.external_identifier_collection && self.external_identifier_collection.external_identifiers.detect {|i| i.identifier_type==Vedaspace::Enum::IdentifierType.ocd_id.to_s }
    
    return ngc
  end

  def ocd_object
    ocd_identifier = national_geo_code
    ocd_identifier && OcdObject.where(ocd_id: ocd_identifier.value).first
  end


  def to_xml_node_with_shapes(node_name = nil)
    if self.national_geo_code && ocd_object
      shape = ocd_object.shapes.last
      shape_data = shape ? shape.shape_data : nil
      if shape_data
        return to_xml_node_without_shapes(node_name) do |node|
          cdata = create_cdata_node(shape_data)
          coo = create_node("Coordinates")
          coo << cdata
          se = create_node("SpatialExtent")
          se << coo
          sd = create_node("SpatialDimension")
          sd << se
          node << sd
        end
      end
    end
    return to_xml_node_without_shapes(node_name)
  end

  alias_method_chain :to_xml_node, :shapes
  
  
  
end
