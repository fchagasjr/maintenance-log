class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, uniqueness: true, presence: true, format: { with: VALID_EMAIL_REGEX, message: "email format not valid" }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  belongs_to :logged_log, class_name: "Log", foreign_key: "log_id"
  has_many :personal_logs, class_name: "Log", foreign_key: "user_id", dependent: :destroy
  has_many :keys, dependent: :destroy
  has_many :request_records, dependent: :nullify
  has_many :service_records, dependent: :nullify

  before_save :downcase_email

  has_secure_password

  has_secure_token :reset_token

  def downcase_email
    self.email.downcase!
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def validate_reset_token(token)
    self.reset_token == token
  end
end