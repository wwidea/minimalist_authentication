# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_path

    assert_response :success
  end

  test "should redirect logged in user" do
    login_as :active_user
    get new_session_path

    assert_redirected_to root_path
  end

  test "should create session" do
    post session_path(user: { email: users(:active_user).email, password: "password" })

    assert_equal users(:active_user), current_user
    assert_redirected_to root_path
  end

  test "should create session and rediret to edit email" do
    users(:active_user).update_columns(email: nil)
    post session_path, params: { user: { username: users(:active_user).username, password: "password" } }

    assert_redirected_to edit_email_path
  end

  test "should create session and redirect to email verification" do
    login_as :legacy_user

    assert_redirected_to new_email_verification_path
  end

  test "should create session and skip email verification" do
    MinimalistAuthentication.configuration.verify_email = false
    login_as :legacy_user

    assert_redirected_to root_path

    MinimalistAuthentication.configuration.verify_email = true
  end

  test "should fail to create session" do
    post session_path(user: { email: users(:active_user).email, password: "wrong_password" })

    assert_nil current_user
    assert_response :unprocessable_entity
  end

  test "should destroy session" do
    login_as :active_user
    delete session_path

    assert_nil current_user
    assert_redirected_to new_session_path
  end
end
