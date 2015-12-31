# This migration comes from vedastore (originally 26)
class CreateVedastoreAnnotatedStrings < ActiveRecord::Migration
  def change
    create_table :vedastore_rails_vssc_annotated_strings do |t|
      t.text :value
      t.string :annotation
      t.timestamps null: false
    end
  end
end
