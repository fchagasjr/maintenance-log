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
    post "/login", params={email: user.email, password: "foobar"}, 'rack.session' => session
  end

  def session
    @session ||= {}
  end
end