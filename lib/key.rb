class Key < ActiveRecord::Base
  belongs_to :log
  belongs_to :user

  validates :user_id, presence: true
  validates :log_id, presence: true
  validates_uniqueness_of :user_id, scope: :log_id
  before_destroy :min_one_admin

  def permissions
    permissions = []
    permissions.push("admin") if admin?
    permissions.push("active") if active?
    permissions.join("/")
  end

  def min_one_admin
    admin_keys = self.log.keys.where(admin: true)
    if admin_keys.one? && admin_keys.include?(self)
      throw(:abort)
    end
  end
end