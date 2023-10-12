class Key < ActiveRecord::Base
  belongs_to :log
  belongs_to :user

  validates :user_id, presence: true
  validates :log_id, presence: true
  validates_uniqueness_of :user_id, scope: :log_id
end