class Entity < ActiveRecord::Base
  belongs_to :assembly
  belongs_to :equipment
  has_many :log_entries

  validates :id, presence: true, uniqueness: true
  validates :description, presence: true
end