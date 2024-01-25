require "pony"

class Mailer
  attr_reader :email, :subject, :html_body, :body

  def initialize(email:, subject:, html_body:, body:)
    @email , @subject, @html_body, @body = email , subject, html_body, body
  end

  def send
    Pony.mail({
      :subject => subject,
      :to => email,
      :body => body,
      :html_body => html_body,
      :via => :smtp,
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => ENV['EMAIL_USER_NAME'],
        :password             => ENV['EMAIL_PASSWORD'],
        :authentication       => :login, # :plain, :login, :cram_md5, no auth by default
        :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
      }
    })
  end
end

class ResetPasswordMailer < Mailer
  def initialize(email:, link:)
    @email = email
    @link = link
  end

  def subject
    "NO REPLY - Logs Buddy - Password Reset"
  end

  def html_body
    "<h3>Your link to reset your password:</h3>" +
    "<a href=#{@link}>Click here!</a>" +
    "<br>" +
    "<p>Ignore this message if you didn't request the reset</p>"
  end

  def body
    "Your link to reset your password: #{@link}"
  end
end