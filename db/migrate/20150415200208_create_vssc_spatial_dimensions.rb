class CreateVsscSpatialDimensions < ActiveRecord::Migration
  def change
    create_table :vssc_spatial_dimensions do |t|
      t.string :object_id
      t.text :map
      t.timestamps null: false
    end
    add_index :vssc_spatial_dimensions, :object_id
    
    add_reference :vssc_spatial_dimensions, :spatial_extent, index: true
  end
end