ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    App
  end

  def login(user)
    user_id = user.id
    log_id = user.logged_log&.id
    env "rack.session", { :user_id => user_id, :log_id => log_id  }
  end

  def logout
    env "rack.session", { :user_id => nil, :log_id => nil }
  end
end
