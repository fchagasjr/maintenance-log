class Key < ActiveRecord::Base
  belongs_to :log
  belongs_to :user

  validates :user_id, presence: true
  validates :log_id, presence: true
end