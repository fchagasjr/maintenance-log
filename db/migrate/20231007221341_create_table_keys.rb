class CreateTableKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :keys do |t|
      t.references :log, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.boolean :admin, default: false
      t.boolean :active, default: false
    end
    add_index :keys, [:log_id, :user_id], unique: true
  end
end
