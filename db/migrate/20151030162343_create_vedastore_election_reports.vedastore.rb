# This migration comes from vedastore (originally 10)
class CreateVedastoreElectionReports < ActiveRecord::Migration
  def change
    create_table :vedastore_election_reports do |t|
      t.integer :election_id
      
      t.text :notes
      
      t.string :format
      t.datetime :generated_date
      t.string :issuer
      t.string :issuer_abbreviation
      t.boolean :is_test
      t.integer :sequence_start
      t.integer :sequence_end
      t.string :status
      t.string :test_type
      t.string :vendor_application_identifier
      
      t.timestamps null: false
    end
    add_index :vedastore_election_reports, :election_id, name: :vedastore_election_reports_election

  end  
end
