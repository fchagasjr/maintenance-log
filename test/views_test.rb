require_relative 'test_helper'

class ViewsTest < AppTest
  attr_reader :foo_user, :bar_user

  def setup
    @foo_user = User.find_by(first_name: "Foo")
    @bar_user = User.find_by(first_name: "Bar")
  end

  def test_logged_and_unlogged_user_home_page
    login(foo_user)
    get "/"
    assert last_response.ok?
    assert last_response.body.include?(foo_user.first_name)
    assert last_response.body.include?(foo_user.logged_log.name)
    refute last_response.body.include?("Login")
    logout
    get "/"
    assert last_response.ok?
    refute last_response.body.include?(foo_user.first_name)
    assert last_response.body.include?("Login")
  end

  def test_login_page
    get "/login"
    assert last_response.ok?
    assert last_response.body.include?("<h2 class=\"title\">Login</h2>")
  end

  def test_signup_page
    get "/signup"
    assert last_response.ok?
    assert last_response.body.include?("<h2 class=\"title\">Sign Up</h2>")
  end
end
