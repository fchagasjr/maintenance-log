class Assembly < ActiveRecord::Base
  belongs_to :log
  has_many :entities, dependent: :destroy

  validates :description, presence: true
end
