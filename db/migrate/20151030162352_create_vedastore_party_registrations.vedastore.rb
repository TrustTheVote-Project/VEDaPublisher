# This migration comes from vedastore (originally 19)
class CreateVedastorePartyRegistrations < ActiveRecord::Migration
  def change
    create_table :vedastore_party_registrations do |t|
      t.string :type
      t.integer :election_report_id
      t.string :party_identifier
      t.integer :count
      
      t.integer :party_registrationable_id
      t.string  :party_registrationable_type
      
      t.timestamps null: false
      
    end    
    add_index :vedastore_party_registrations, :election_report_id, name: :vedastore_party_registration_election_report
    add_index :vedastore_party_registrations, :party_identifier, name: :vedastore_party_reg_identifier
    add_index :vedastore_party_registrations, [:party_registrationable_id, :party_registrationable_type], name: :vedastore_party_registrationable
    
  end  
end
