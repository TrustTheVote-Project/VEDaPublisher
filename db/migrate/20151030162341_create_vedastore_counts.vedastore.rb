# This migration comes from vedastore (originally 8)
class CreateVedastoreCounts < ActiveRecord::Migration
  def change
    create_table :vedastore_counts do |t|
      t.string :type

      t.integer :countable_id
      t.string :countable_type

      t.integer :device_id
      
      t.string :gp_unit_identifier
      t.boolean :is_suppressed_for_privacy
      t.string :other_type
      t.string :count_item_type
      
      t.timestamps null: false
      
      #summary_counts
      t.integer :ballots_cast
      t.integer :ballots_outstanding
      t.integer :ballots_rejected
      t.integer :overvotes
      t.integer :undervotes
      t.integer :write_ins
      
      t.integer :summary_countable_id
      t.string  :summary_countable_type
      
      #vote counts
      t.float :count      
    end
    add_index :vedastore_counts, :type, name: :vedastore_counts_type
    add_index :vedastore_counts, [:countable_id, :countable_type], name: :vedastore_countable
    add_index :vedastore_counts, :device_id, name: :vedastore_counts_device
    add_index :vedastore_counts, :gp_unit_identifier, name: :vedastore_counts_gp_unit
    add_index :vedastore_counts, [:summary_countable_id, :summary_countable_type], name: :vedastore_counts_summary_countable
    
  end  
end
