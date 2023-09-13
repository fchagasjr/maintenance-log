class ServiceRecord < ActiveRecord::Base
  belongs_to :request_record
  belongs_to :service_type

  validates :request_record_id, presence: true
  validates :service_type_id, presence: true
end