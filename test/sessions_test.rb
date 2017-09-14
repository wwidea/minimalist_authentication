require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include MinimalistAuthentication::TestHelper

  test "should get new" do
    get new_session_path
    assert_response :success
  end

  test "should create session" do
    post session_path(user: { email: 'test@testing.com', password: 'password' } )
    assert_equal users(:active_user), current_user
    assert_redirected_to root_path
  end

  test "should fail to create session" do
    post session_path(user: { email: 'test@testing.com', password: 'wrong_password' } )
    assert_nil current_user
    assert_response :success
  end

  test "should destroy session" do
    login_as :active_user
    delete session_path
    assert_nil current_user
    assert_redirected_to new_session_path
  end
end
