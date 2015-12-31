# This migration comes from vedastore (originally 14)
class CreateVedastoreInternationalizedTexts < ActiveRecord::Migration
  def change
    create_table :vedastore_internationalized_texts do |t|
      t.string :label
      
      t.timestamps null: false
    end
    
  end  
end
