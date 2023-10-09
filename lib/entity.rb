class Entity < ActiveRecord::Base
  belongs_to :assembly
  has_many :request_records

  validates :number, presence: true
  validates :description, presence: true
  validates :assembly_id, presence: true

  before_validation :upcase_number

  default_scope { order(number: :asc) }

  private
  def upcase_number
    self.number.upcase!
  end
end