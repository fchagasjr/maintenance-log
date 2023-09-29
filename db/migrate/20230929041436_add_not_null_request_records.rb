class AddNotNullRequestRecords < ActiveRecord::Migration[7.0]
  def change
    change_column_null :request_records, :user_id, false
    change_column_null :service_records, :user_id, false
  end
end
