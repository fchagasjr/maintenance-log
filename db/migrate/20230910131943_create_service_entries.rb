class CreateServiceEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :service_entries do |t|
      t.string :type, null: false
      t.text :description, null: false
      t.date :closed_at
      t.references :entity, type: :string, null: false, foreign_key: true

      t.timestamps
    end
    add_index :service_entries, [:entity_id, :updated_at]
  end
end
