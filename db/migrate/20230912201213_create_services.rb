class CreateServices < ActiveRecord::Migration[7.0]
  def change
    create_table :services do |t|
      t.references :log_entry, null: false, foreign_key: true
      t.string :description
      t.text :details
      t.date :closed_at
    end
  end
end
