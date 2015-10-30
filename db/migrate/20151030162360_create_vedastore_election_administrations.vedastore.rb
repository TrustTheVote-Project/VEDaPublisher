# This migration comes from vedastore (originally 27)
class CreateVedastoreElectionAdministrations < ActiveRecord::Migration
  def change
    create_table :vedastore_election_administrations do |t|
      t.integer  :contact_information_id
      t.string :name
      
      t.timestamps null: false
    end
    add_index :vedastore_election_administrations, :contact_information_id, name: :vedastore_election_admin_contact_information
    
    create_table :vedastore_election_administration_official_id_refs do |t|
      t.integer :election_administration_id
      t.string :election_official_id_ref
    end
    add_index :vedastore_election_administration_official_id_refs, [:election_administration_id, :election_official_id_ref], name: :vedastore_election_admin_official_ref
    
  end  
end
