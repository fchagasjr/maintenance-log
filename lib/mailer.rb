require "pony"

class Mailer
  def initialize(to:, subject:, html_body:, body:)
    @to , @subject, @html_body, @body = to , subject, html_body, body
  end

  def send
    Pony.mail({
      :subject => @subject,
      :to => @to,
      :body => @body,
      :html_body => @html_body,
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
