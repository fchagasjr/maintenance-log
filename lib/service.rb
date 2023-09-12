class Service < ActiveRecord::Base
  belongs_to :log_entry

  validates :log_entry_id, presence: true, uniqueness: true
  validates :description, presence: true
end