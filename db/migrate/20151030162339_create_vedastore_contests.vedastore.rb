# This migration comes from vedastore (originally 6)
class CreateVedastoreContests < ActiveRecord::Migration
  def change
    create_table :vedastore_contests do |t|
      t.string :type
      
      t.integer :election_id
      
      t.integer :ballot_sub_title_id
      t.integer :ballot_title_id
      
      t.string :electoral_district_identifier
      t.string :name
      
      t.string :object_id
      t.string :abbreviation
      t.boolean :has_rotation
      t.string :other_vote_variation
      t.integer :sequence_order
      t.integer :sub_units_reported
      t.integer :total_sub_units
      t.string :vote_variation
      
      t.timestamps null: false
      
      #ballot_measure_contest
      t.integer :con_statement_id
      t.integer :effect_of_abstain_id
      t.integer :full_text_id
      t.integer :passage_threshold_id
      t.integer :pro_statement_id
      t.integer :summary_text_id
  
      t.string :other_type
      t.string :ballot_measure_type
      
      #candidate_contest
      t.string :primary_party_identifier

      t.integer :number_elected
      t.integer :votes_allowed
      
      
      #retention_contest
      t.string :candidate_identifier
      t.string :office_identifier      
    end
    add_index :vedastore_contests, :election_id, name: :vedastore_contest_election
    add_index :vedastore_contests, :ballot_sub_title_id, name: :vedastore_contest_ballot_sub_title
    add_index :vedastore_contests, :ballot_title_id, name: :vedastore_contest_ballot_title
    add_index :vedastore_contests, :object_id, name: :vedastore_contest_object_id
    
    add_index :vedastore_contests, :con_statement_id, name: :vedastore_ballot_measure_con_statement
    add_index :vedastore_contests, :effect_of_abstain_id, name: :vedastore_ballot_measure_effect_of_abstain
    add_index :vedastore_contests, :full_text_id, name: :vedastore_ballot_measure_full_text
    add_index :vedastore_contests, :passage_threshold_id, name: :vedastore_ballot_measure_passage_threshold
    add_index :vedastore_contests, :pro_statement_id, name: :vedastore_ballot_measure_pro_statement
    add_index :vedastore_contests, :summary_text_id, name: :vedastore_ballot_measure_summary_text
    
    add_index :vedastore_contests, :primary_party_identifier, name: :vedastore_can_con_primary_party
    
    add_index :vedastore_contests, :candidate_identifier, name: :vedastore_ret_con_candidate
    add_index :vedastore_contests, :office_identifier, name: :vedastore_ret_con_office
    
    
    #candidate_contest
    create_table :vedastore_contest_office_id_refs do |t|
      t.integer :contest_id
      t.string :office_id_ref
    end
    add_index :vedastore_contest_office_id_refs, [:contest_id, :office_id_ref], name: :vedastore_contest_offices
    
  end  
end
