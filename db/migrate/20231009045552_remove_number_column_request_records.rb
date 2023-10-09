class RemoveNumberColumnRequestRecords < ActiveRecord::Migration[7.0]
  def change
    remove_column :request_records, :number, :string
    change_column_null :request_records, :entity_id, false
    change_column_null :entities, :number, false
    add_index :entities, [:number, :assembly_id], unique: true
  end
end
