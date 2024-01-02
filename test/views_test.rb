ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'test/unit'
require 'rack/test'

class ViewsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    App
  end


  def login(user)
    post "/login", params={email: user.email, password: "foobar"}
  end

  def test_not_logged_user_home_page
    get "/"
    assert last_response.ok?
    assert last_response.body.include?("Login")
  end


  def test_logged_user_home_page
    login(User.first)
    get "/"
    assert last_response.ok?
    assert last_response.body.include?(User.first.first_name)
  end

  def test_login_page
    get "/login"
    assert last_response.ok?
    assert last_response.body.include?("Login")
  end
end