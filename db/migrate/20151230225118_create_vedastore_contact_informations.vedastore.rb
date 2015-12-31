# This migration comes from vedastore (originally 5)
class CreateVedastoreContactInformations < ActiveRecord::Migration
  def change
    create_table :vedastore_contact_informations do |t|
      t.integer :contactable_id
      t.string :contactable_type

      t.text :address_line
      t.text :email
      t.text :fax
      t.string :name
      t.text :phone

      t.text :uri
      t.timestamps null: false
    end
    add_index :vedastore_contact_informations, [:contactable_id, :contactable_type], name: :vedastore_contactable

  end  
end
