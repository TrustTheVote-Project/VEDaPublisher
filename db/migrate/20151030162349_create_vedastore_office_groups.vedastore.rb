# This migration comes from vedastore (originally 16)
class CreateVedastoreOfficeGroups < ActiveRecord::Migration
  def change
    create_table :vedastore_office_groups do |t|
      t.integer :office_groupable_id
      t.string :office_groupable_type
      
      t.string :name
      t.string :label
      
      t.timestamps null: false
    end
    add_index :vedastore_office_groups, [:office_groupable_id, :office_groupable_type], name: :vedastore_office_groupable
    
    create_table :vedastore_office_group_office_ids do |t|
      t.integer :office_id
      t.string :office_id_ref
    end
    add_index :vedastore_office_group_office_ids, [:office_id, :office_id_ref], name: :vedastore_office_group_office_refs
    
  end  
end
