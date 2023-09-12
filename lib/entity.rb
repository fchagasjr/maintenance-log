class Entity < ActiveRecord::Base
  belongs_to :assembly

  validates :id, presence: true, uniqueness: true
  validates :description, presence: true

  before_save :upcase_id

  private
  def upcase_id
    self.id.upcase!
  end
end