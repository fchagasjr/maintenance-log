class Assembly < ActiveRecord::Base
  validates :description, presence: true
end
