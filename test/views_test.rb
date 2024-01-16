require_relative 'test_helper'

class ViewsTest < AppTest
  attr_reader :user

  fixtures :all

  def setup
    @user = User.first
  end

  def test_not_logged_user_home_page
    get "/"
    assert last_response.ok?
    assert last_response.body.include?("Login")
  end

  def test_logged_user_home_page
    login(user)
    get "/"
    assert last_response.body.include?(user.first_name)
    logout
    get "/"
    refute last_response.body.include?(user.first_name)
  end

  def test_login_page
    get "/login"
    assert last_response.ok?
    assert last_response.body.include?("Login")
  end
end
