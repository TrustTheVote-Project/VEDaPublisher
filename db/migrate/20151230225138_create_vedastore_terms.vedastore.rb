# This migration comes from vedastore (originally 25)
class CreateVedastoreTerms < ActiveRecord::Migration
  def change
    create_table :vedastore_terms do |t|
      t.date :end_date
      t.date :start_date
      t.string :office_term_type
      
      t.string :label
      
      t.timestamps null: false
    end
  end  
end
