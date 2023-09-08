class Entity < ActiveRecord::Base
  validates :id, presence: true
  validates :description, presence: true
end