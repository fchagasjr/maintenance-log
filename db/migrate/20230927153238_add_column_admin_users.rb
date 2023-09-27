class AddColumnAdminUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :admin, :boolean, default: false
    add_column :users, :active, :boolean, default: false
  end
end
