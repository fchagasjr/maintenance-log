class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, uniqueness: true, presence: true, format: { with: VALID_EMAIL_REGEX, message: "email format not valid" }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  has_many :request_records
  has_many :service_records

  before_save :downcase_email

  has_secure_password

  def downcase_email
    self.email.downcase!
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end