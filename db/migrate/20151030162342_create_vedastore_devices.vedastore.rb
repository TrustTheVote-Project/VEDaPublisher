# This migration comes from vedastore (originally 9)
class CreateVedastoreDevices < ActiveRecord::Migration
  def change
    create_table :vedastore_devices do |t|
      t.string :manufacturer
      t.string :model
      t.string :device_type
      
      t.timestamps null: false
    end
    
  end  
end
