class FaultEntry < ActiveRecord::Base
  belongs_to :entity
  belongs_to :service_entry

  validates :entity_id, presence: true
  validates :description, presence: true
end