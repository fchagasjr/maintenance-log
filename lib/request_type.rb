class ResquestTypes < ActiveRecord::Base
  has_many :request_records, dependent: :destroy
end