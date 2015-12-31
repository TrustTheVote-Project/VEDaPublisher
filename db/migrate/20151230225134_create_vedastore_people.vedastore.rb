# This migration comes from vedastore (originally 21)
class CreateVedastorePeople < ActiveRecord::Migration
  def change
    create_table :vedastore_people do |t|
      t.integer :election_report_id
      t.string :first_name
      t.integer :full_name_id
      t.string :last_name
      t.text :middle_names
      t.string :nickname
      t.string :party_identifier
      t.string :prefix
      t.integer :profession_id
      t.string :sufix
      t.integer :title_id
      
      t.string :object_id
      t.date :date_of_birth
      t.string :gender
      
      t.timestamps null: false
    end
    add_index :vedastore_people, :election_report_id, name: :vedastore_person_election_report
    add_index :vedastore_people, :full_name_id, name: :vedastore_person_full_name
    add_index :vedastore_people, :profession_id, name: :vedastore_person_profession
    add_index :vedastore_people, :title_id, name: :vedastore_perspon_title
    add_index :vedastore_people, :object_id, name: :vedastore_person_object_id
    
  end  
end
