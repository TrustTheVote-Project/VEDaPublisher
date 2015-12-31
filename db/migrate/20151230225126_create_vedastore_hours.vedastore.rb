# This migration comes from vedastore (originally 13)
class CreateVedastoreHours < ActiveRecord::Migration
  def change
    create_table :vedastore_hours do |t|
      
      t.integer :hourable_id
      t.string :hourable_type
      
      t.string :day
      t.datetime :end_time
      t.datetime :start_time
      
      t.string :label
      
      t.timestamps null: false
    end
    add_index :vedastore_hours, [:hourable_id, :hourable_type], name: :vedastore_hourable
  end  
end
