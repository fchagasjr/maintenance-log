class Assembly < ActiveRecord::Base
  belongs_to :log
  has_many :entities, dependent: :nullify

  validates :description, presence: true
end
