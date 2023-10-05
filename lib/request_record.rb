class RequestRecord < ActiveRecord::Base
  belongs_to :entity
  belongs_to :request_type
  belongs_to :user
  has_one :service_record
  
  validates :entity_id, presence: true
  validates :request_type, presence: true
  validates :user_id, presence: true

  def self.by_assembly(assembly)
    self.joins(:entity)
        .where(entity: { assembly_id: assembly.id })
  end

  def self.by_entity(entity)
    self.where(entity_id: entity.id)
  end

  def self.by_priority
    left_outer_joins(:service_record)
    .order(
      Arel.sql(
        "CASE " \
        "WHEN service_records.id IS NULL THEN 0 " \
        "WHEN closed_at IS NULL THEN 1 " \
        "ELSE 2 END, " \
        "closed_at DESC NULLS LAST"
        )
      )
  end
end
