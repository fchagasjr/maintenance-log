class Entity < ActiveRecord::Base
  belongs_to :assembly
  has_many :request_records, dependent: :destroy
  has_one :log, through: :assembly

  validates :number, presence: true
  validates_uniqueness_of :number, scope: :assembly_id
  validates :description, presence: true
  validates :assembly_id, presence: true
  validate :uniq_number_per_log

  before_validation :upcase_number

  default_scope { order(number: :asc) }

  private
  def upcase_number
    self.number.upcase!
  end

  def uniq_number_per_log
    entity_log = self.log
    same_number_entity = entity_log.entities.find_by(number: self.number)
    unless same_number_entity.nil? || same_number_entity == self
      errors.add(:number, "was found in the log")
    end
  end
end