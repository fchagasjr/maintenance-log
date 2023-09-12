class CreateEntities < ActiveRecord::Migration[7.0]
  def change
    create_table :entities, id: false do |t|
      t.string :id, primary_key: true
      t.string :description, null: false
      t.references :assembly, foreign_key: true
    end
  end
end
