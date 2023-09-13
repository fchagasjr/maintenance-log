class CreateRequestRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :request_records do |t|
      t.references :entity, type: :string, null:false, foreign_key: true
      t.references :request_type, null: false, foreign_key: true
      t.text :description
    end
  end
end
