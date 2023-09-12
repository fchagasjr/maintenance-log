class CreateLogEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :log_entries do |t|
      t.references :entity, type: :string, null: false, foreign_key: true
      t.string :fault
      t.string :service
      t.text :details
      t.date :closed_at

      t.timestamps
    end
  end
end