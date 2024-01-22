class Key < ActiveRecord::Base
  belongs_to :log
  belongs_to :user

  validates :user_id, presence: true
  validates :log_id, presence: true
  validates_uniqueness_of :user_id, scope: :log_id
  validate :no_owner_key

  def permissions
    permissions = []
    permissions.push("admin") if admin?
    permissions.push("active") if active?
    permissions.join("/")
  end

  private
  def no_owner_key
    if self.log.owner_user == self.user
      errors.add(:user_id, "is already the owner of the log")
    end
  end
end