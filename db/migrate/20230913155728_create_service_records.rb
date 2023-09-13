class CreateServiceRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :service_types do |t|
      t.string :description
    end

    create_table :service_records do |t|
      t.references :request_record, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.text :description
      t.date :closed_at
    end
  end
end
