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
    env "rack.session", { :user_id => user.id }
  end

  def logout
    env "rack.session", { :user_id => nil }
  end
end
