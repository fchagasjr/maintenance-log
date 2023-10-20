class AddNotNullOwnerTableLog < ActiveRecord::Migration[7.0]
  def change
    change_column_null :logs, :user_id, false
  end
end
