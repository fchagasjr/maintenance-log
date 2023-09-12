class LogEntry < ActiveRecord::Base
  belongs_to :entity
  has_one :service

  validates :entity_id, presence: true
end