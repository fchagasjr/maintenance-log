class ServiceEntry < ActiveRecord::Base
  belongs_to :entity
  has_one :fault_entry

  validates :entity_id, presence: true
  validates :type, presence: true
  validates :description, presence: true
end