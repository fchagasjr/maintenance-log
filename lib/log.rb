class Log < ActiveRecord::Base
  has_many :users
  has_many :keys
  has_many :assemblies

  validates :name, presence: true
end