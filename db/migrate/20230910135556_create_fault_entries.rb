class CreateFaultEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :fault_entries do |t|
      t.text :description
      t.references :entity, type: :string, null: false, foreign_key: true
      t.references :service_entry, foreign_key: true

      t.timestamps
    end
    add_index :fault_entries, [:entity_id, :updated_at]
  end
end
