class Entity < ActiveRecord::Base
  belongs_to :assembly
  has_many :request_records

  validates :id, presence: true, uniqueness: true
  validates :description, presence: true
  validates :assembly_id, presence: true

  before_validation :upcase_id

  private
  def upcase_id
    self.id.upcase!
  end
end