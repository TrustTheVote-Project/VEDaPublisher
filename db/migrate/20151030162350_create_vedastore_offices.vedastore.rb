# This migration comes from vedastore (originally 17)
class CreateVedastoreOffices < ActiveRecord::Migration
  def change
    create_table :vedastore_offices do |t|
      t.integer :office_group_id
      t.integer :election_report_id
      
      t.integer :contact_information_id
      
      t.string :electoral_district_identifier
      t.integer :name_id
      
      t.integer :term_id
      
      t.string :object_id
      t.datetime :filing_deadline
      t.boolean :is_partisan
      
      t.timestamps null: false
    end
    add_index :vedastore_offices, :election_report_id, name: :vedastore_office_election_report
    add_index :vedastore_offices, :office_group_id, name: :vedastore_office_office_group
    add_index :vedastore_offices, :contact_information_id, name: :vedastore_office_contact_information
    add_index :vedastore_offices, :electoral_district_identifier, name: :vedastore_office_jurisdiction_scope
    add_index :vedastore_offices, :name_id, name: :vedastore_office_name
    add_index :vedastore_offices, :term_id, name: :vedastore_office_term
    add_index :vedastore_offices, :object_id, name: :vedastore_office_object_id
    
    
    create_table :vedastore_office_office_holder_id_refs do |t|
      t.integer :office_id
      t.string :office_holder_id_ref
    end
    add_index :vedastore_office_office_holder_id_refs, [:office_id, :office_holder_id_ref], name: :vedastore_office_office_holder_ref
    
  end  
end
