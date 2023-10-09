class ChangeEntityColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :entities, :number, :string
    add_column :request_records, :number, :string
  end
end
