class Entity < ActiveRecord::Base
  belongs_to :assembly
  has_many :request_records

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
    entity_log = self.assembly.log
    entity_log.assemblies.each do |assembly|
      if assembly.entities.find_by(number: self.number)
        errors.add(:number, "was found in the log")
      end
    end
  end
end