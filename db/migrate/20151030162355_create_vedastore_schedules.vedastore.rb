# This migration comes from vedastore (originally 22)
class CreateVedastoreSchedules < ActiveRecord::Migration
  def change
    create_table :vedastore_schedules do |t|
      t.integer :schedulable_id
      t.string :schedulable_type
      
      t.date :end_date
      t.date :start_date
      t.boolean :is_only_by_appointment
      t.boolean :is_or_by_appointment
      t.boolean :is_subject_to_change
      
      t.string :label
      
      t.timestamps null: false
    end
    add_index :vedastore_schedules, [:schedulable_id, :schedulable_type], name: :vedastore_schedulable
  end  
end
