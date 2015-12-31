# This migration comes from vedastore (originally 20)
class CreateVedastoreParties < ActiveRecord::Migration
  def change
    create_table :vedastore_parties do |t|
      t.integer :election_report_id
      t.integer :name_id

      t.string :object_id
      t.string :abbreviation
      t.string :color
      t.string :logo_uri
      
      t.timestamps null: false

      #coalition
      t.string :contest_identifier
  
    end
    add_index :vedastore_parties, :election_report_id, name: :vedastore_party_election_report
    add_index :vedastore_parties, :name_id, name: :vedastore_party_name
    add_index :vedastore_parties, :object_id, name: :vedastore_party_object_id
    add_index :vedastore_parties, :contest_identifier, name: :vedastore_party_contest
    
    #coaltion
    create_table :vedastore_party_party_id_refs do |t|
      t.integer :party_id
      t.string :party_id_ref
    end
    add_index :vedastore_party_party_id_refs, [:party_id, :party_id_ref], name: :vedastore_party_party_id_ref

    create_table :vedastore_party_contest_id_refs do |t|
      t.integer :party_id
      t.string :contest_id_ref
    end
    add_index :vedastore_party_contest_id_refs, [:party_id, :contest_id_ref], name: :vedastore_party_contest_id_ref
    

  end  
end
