class Log < ActiveRecord::Base
  belongs_to :owner_user, class_name: "User", foreign_key: "user_id"

  has_many :logged_users, class_name: "User", foreign_key: "log_id"
  has_many :keys, dependent: :destroy
  has_many :assemblies, dependent: :destroy
  has_many :entities, through: :assemblies

  validates :name, presence: true
  validates :user_id, presence: true
end