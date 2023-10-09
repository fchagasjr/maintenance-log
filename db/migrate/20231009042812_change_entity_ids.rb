class ChangeEntityIds < ActiveRecord::Migration[7.0]
  def change
    remove_reference :request_records, :entity, foreign_key: true
    remove_column :entities, :id, :string
    add_column :entities, :id, :primary_key
    add_reference :request_records, :entity, foreign_key: true
  end
end