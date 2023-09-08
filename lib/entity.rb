class Entity < ActiveRecord::Base
  validates :description, presence: true
end