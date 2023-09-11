class Service < ActiveRecord::Base
  has_many :log_entries

  validates :description, presence: true
end