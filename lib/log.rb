class Log < ActiveRecord::Base
  has_many :assemblies
  has_many :keys

  validates :name, presence: true
end