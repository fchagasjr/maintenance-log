class Group < ActiveRecord::Base
  has_many :entities, dependent: :nullify

  validates :description, presence: true
end
