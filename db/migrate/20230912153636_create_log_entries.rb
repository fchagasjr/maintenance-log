class CreateLogEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :log_entries do |t|
      t.references :entity, type: :string, null: false, foreign_key: true
      t.text :info
    end
  end
end