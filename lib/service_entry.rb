class ServiceEntry < ActiveRecord::Base
  belongs_to :entity

  validates :type, presence: true
  validates :type, presence: true
end