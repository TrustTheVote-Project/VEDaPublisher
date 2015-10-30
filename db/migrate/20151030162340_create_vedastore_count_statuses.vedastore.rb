# This migration comes from vedastore (originally 7)
class CreateVedastoreCountStatuses < ActiveRecord::Migration
  def change
    create_table :vedastore_count_statuses do |t|
      t.integer :count_statusable_id
      t.string :count_statusable_type
      
      t.string :other_type
      t.string :status
      t.string :count_item_type
      
      t.timestamps null: false
    end
    add_index :vedastore_count_statuses, [:count_statusable_id, :count_statusable_type], name: :vedastore_count_statusable

  end  
end
