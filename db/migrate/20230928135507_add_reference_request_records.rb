class AddReferenceRequestRecords < ActiveRecord::Migration[7.0]
  def change
    add_reference :request_records, :user, foreign_key: true
    add_reference :service_records, :user, foreign_key: true
  end
end
