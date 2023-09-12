class LogEntry < ActiveRecord::Base
  belongs_to :entity

  validates :entity_id, presence: true
end