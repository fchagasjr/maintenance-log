class Entity < ActiveRecord::Base
  validates :id, presence: true, uniqueness: true
  validates :description, presence: true
end