class AddColumnResetTokenUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :reset_token, :string
  end
end
