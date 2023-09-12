class CreateAssemblies < ActiveRecord::Migration[7.0]
  def change
    create_table :assemblies do |t|
      t.string :description, null: false
      t.string :manufacturer
      t.string :model
    end
  end
end
