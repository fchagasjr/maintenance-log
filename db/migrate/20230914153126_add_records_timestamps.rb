class AddRecordsTimestamps < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :request_records
    add_timestamps :service_records

    add_index :request_records, :created_at, order: { created_at: :desc }
  end
end
