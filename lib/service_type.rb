class ServiceType < ActiveRecord::Base
  has_many :service_records, dependent: :destroy
end