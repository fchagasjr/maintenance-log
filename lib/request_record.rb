class RequestRecord < ActiveRecord::Base
  belongs_to :entity
  belongs_to :request_type
  has_one :service_record
  
  validates :entity_id, presence: true
  validates :request_type, presence: true

  def self.all_by_priority
    self.left_outer_joins(:service_record).reverse
  end

  def self.by_assembly(assembly)
    self.joins(:entity)
        .where(entity: { assembly_id: assembly.id })
        .left_outer_joins(:service_record)
        .reverse
  end

  def self.by_entity(entity)
    self.where(entity_id: entity.id)
        .left_outer_joins(:service_record)
        .reverse
   end
end
