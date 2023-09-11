class CreateLogEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :log_entries do |t|
      t.text :open_description
      t.references :service, foreign_key: true
      t.text :close_description
      t.date :closed_at
      t.references :entity, type: :string, null: false, foreign_key: true

      t.timestamps
    end
  end
end