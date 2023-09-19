class RequestRecord < ActiveRecord::Base
  belongs_to :entity
  belongs_to :request_type
  has_one :service_record
  
  validates :entity_id, presence: true
  validates :request_type, presence: true
end
