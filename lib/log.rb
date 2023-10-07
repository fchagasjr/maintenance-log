class Log < ActiveRecord::Base
  has_many :assemblies

  validates :name, presence: true
end