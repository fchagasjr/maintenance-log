class AddColumnSerialNumber < ActiveRecord::Migration[7.0]
  def change
    add_column :entities, :serial, :string

    change_column_null :entities, :assembly_id, false
  end
end
