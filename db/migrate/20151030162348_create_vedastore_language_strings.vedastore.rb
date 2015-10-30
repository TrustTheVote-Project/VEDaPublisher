# This migration comes from vedastore (originally 15)
# define_attribute("Language") #type: "xsd:language"
class CreateVedastoreLanguageStrings < ActiveRecord::Migration
  def change
    create_table :vedastore_language_strings do |t|
      t.integer :internationalized_text_id
      t.string :language
      t.text :text
      
      t.timestamps null: false
    end
    add_index :vedastore_language_strings, :internationalized_text_id, name: :vedastore_language_string_internationalized_text
  end  
end
