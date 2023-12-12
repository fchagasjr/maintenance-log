ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'test/unit'
require 'rack/test'

class ViewsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file("config.ru").first
  end

  def test_home_page
    AppHelpers.login(User.first)
    get "/"
    assert last_response.ok?
    puts last_response.body
  end

  def test_login_page
    get "/login"
    assert last_response.ok?
    assert last_response.body.include?("Login")
  end
end