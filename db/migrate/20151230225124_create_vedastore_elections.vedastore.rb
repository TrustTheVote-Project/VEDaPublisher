# This migration comes from vedastore (originally 11)
class CreateVedastoreElections < ActiveRecord::Migration
  def change
    create_table :vedastore_elections do |t|
      t.integer :contact_information_id
      
      t.string :election_scope_identifier
      
      t.integer :name_id
      
      t.date :start_date
      t.date :end_date
      t.string :election_type
      
      t.timestamps null: false
    end
    add_index :vedastore_elections, :contact_information_id, name: :vedastore_election_contact_information
    add_index :vedastore_elections, :election_scope_identifier, name: :vedastore_elections_gp_scope
    add_index :vedastore_elections, :name_id, name: :vedastore_elections_name
    
  end  
end
