# This migration comes from vedastore (originally 18)
class CreateVedastoreOrderedContests < ActiveRecord::Migration
  def change
    create_table :vedastore_ordered_contests do |t|
      t.integer  :ballot_style_id
      t.string :contest_identifier
      
      t.timestamps null: false
    end
    add_index :vedastore_ordered_contests, :ballot_style_id, name: :vscc_ordered_contest_ballot_style
    add_index :vedastore_ordered_contests, :contest_identifier, name: :vedastore_ordered_contest_identifier
    
    create_table :vedastore_ordered_contest_ballot_selection_id_refs do |t|
      t.integer :ordered_contest_id
      t.string :ballot_selection_id_ref
    end
    add_index :vedastore_ordered_contest_ballot_selection_id_refs, [:ordered_contest_id, :ballot_selection_id_ref], name: :vedastore_ordered_contest_ballot_selection_ref
    
  end  
end
