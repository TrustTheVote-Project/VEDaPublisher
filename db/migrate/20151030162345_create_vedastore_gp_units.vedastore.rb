# This migration comes from vedastore (originally 12)
class CreateVedastoreGpUnits < ActiveRecord::Migration
  def change
    create_table :vedastore_gp_units do |t|
      t.string :type

      t.integer :election_report_id
      
      t.string :object_id
      t.string :name
      
      t.timestamps null: false
      
      #reporting_device
      t.integer :device_id
      t.string :serial_number
      
      #reporting_unit  
      t.integer :contact_information_id
      t.integer :election_administration_id
      
      t.text :count_statuses

      t.integer :spatial_dimension_id

      t.boolean :is_districted
      t.boolean :is_mail_only
      
      t.string :number
      t.string :other_type
      t.integer :sub_units_reported
      t.integer :total_sub_units
      t.string :reporting_unit_type
      t.integer :voters_participated
      t.integer :voters_registered
      
    end
    add_index :vedastore_gp_units, :election_report_id, name: :vscc_gp_unit_election_report
    add_index :vedastore_gp_units, :type, name: :vedastore_gp_unit_type
    add_index :vedastore_gp_units, :object_id, name: :vedastore_gp_unit_object_id
    add_index :vedastore_gp_units, :contact_information_id, name: :vedastore_gp_unit_contact_info
    add_index :vedastore_gp_units, :spatial_dimension_id, name: :vedastore_gp_unit_spatial_dimension
    
    create_table :vedastore_gp_unit_composing_gp_unit_id_refs do |t|
      t.integer :gp_unit_id
      t.string :composing_gp_unit_id_ref
    end
    add_index :vedastore_gp_unit_composing_gp_unit_id_refs, [:gp_unit_id, :composing_gp_unit_id_ref], name: :vedastore_gp_unit_composing_units
    
    #reporting_unit
    create_table :vedastore_gp_unit_authority_id_refs do |t|
      t.integer :gp_unit_id
      t.string :authority_id_ref
    end
    add_index :vedastore_gp_unit_authority_id_refs, [:gp_unit_id, :authority_id_ref], name: :vedastore_gp_unit_authorities
    
    
  end  
end
