# frozen_string_literal: true

require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_password_reset_path

    assert_response :success
  end

  test "should create password reset email for known user" do
    assert_emails(1) { post password_reset_path(user: { email: users(:active_user).email }) }
    assert_redirected_to new_session_path
  end

  test "should fail to create password reset email for unknown user" do
    assert_no_emails { post password_reset_path(user: { email: "not_a_user@example.com" }) }
    assert_redirected_to new_session_path
  end

  test "should fail to create password reset email when email parameter is not provided" do
    assert_no_emails { post password_reset_path(user: { foo: "bar" }) }
    assert_response :unprocessable_entity
  end

  test "should fail to create password reset email when users is missing" do
    assert_no_emails { post password_reset_path(foo: "bar") }
    assert_response :unprocessable_entity
  end
end
