class LogEntry < ActiveRecord::Base
  belongs_to :entity
  belongs_to :service

  validates :entity_id, presence: true
end