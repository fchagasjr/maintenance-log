class CreateTableLog < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :assemblies, :log, foreign_key: true
  end
end
