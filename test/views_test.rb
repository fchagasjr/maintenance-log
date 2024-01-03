require_relative 'test_helper'

class ViewsTest < AppTest
  def test_not_logged_user_home_page
    get "/"
    assert last_response.ok?
    assert last_response.body.include?("Login")
  end

  def test_logged_user_home_page
    user = User.first
    login(user)
    get "/", {}, 'rack.session' => session # Passing the session to the request through rack.session
    assert last_response.body.include?(user.first_name)
  end

  def test_login_page
    get "/login"
    assert last_response.ok?
    assert last_response.body.include?("Login")
  end
end
