class CreateAssemblies < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :description, null: false
    end
  end
end
