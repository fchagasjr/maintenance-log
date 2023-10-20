class AddOwnerTableLog < ActiveRecord::Migration[7.0]
  def change
    add_reference :logs, :user, foreign_key: true
  end
end
