# This migration comes from vedastore (originally 24)
class CreateVedastoreSpatialExtents < ActiveRecord::Migration
  def change
    create_table :vedastore_spatial_extents do |t|
      t.text :coordinates
      t.string :format
      
      t.timestamps null: false
    end
  end  
end
