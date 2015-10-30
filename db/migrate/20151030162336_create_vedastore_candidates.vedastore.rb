# This migration comes from vedastore (originally 3)
class CreateVedastoreCandidates < ActiveRecord::Migration
  def change
    create_table :vedastore_candidates do |t|
      t.integer :election_id
      t.integer :ballot_name_id
      
      t.string :party_identifier
      t.string :person_identifier
      
      t.string :object_id
      t.date :file_date
      t.boolean :is_incumbent
      t.boolean :is_top_ticket
      t.string :post_election_status
      t.string :pre_election_status
      
      t.timestamps null: false
    end
    add_index :vedastore_candidates, :election_id, name: :vedastore_candidate_election
    add_index :vedastore_candidates, :ballot_name_id, name: :vedastore_candidate_ballot_name
    add_index :vedastore_candidates, :object_id, name: :vedastore_candidate_object_id
    
  end  
end
