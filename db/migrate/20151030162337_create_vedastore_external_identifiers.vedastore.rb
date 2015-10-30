# This migration comes from vedastore (originally 4)
class CreateVedastoreExternalIdentifiers < ActiveRecord::Migration
  def change
    create_table :vedastore_external_identifier_collections do |t|
      t.string :identifiable_type
      t.integer :identifiable_id
      t.string :label
      
      t.timestamps null: false
    end
    
    create_table :vedastore_external_identifiers do |t|
      t.integer :external_identifier_collection_id
      
      t.string :identifier_type
      t.string :other_type
      t.string :value
      
      t.string :label
      
      t.timestamps null: false
    end
    add_index :vedastore_external_identifier_collections, [:identifiable_type, :identifiable_id], name: :vedastore_identifiable
  end  
end
