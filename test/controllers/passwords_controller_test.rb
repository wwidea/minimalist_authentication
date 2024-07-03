# frozen_string_literal: true

require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit for verified user" do
    users(:active_user).regenerate_verification_token
    get edit_user_password_path(users(:active_user), token: users(:active_user).verification_token)

    assert_response :success
  end

  test "should fail to get edit for unverifed user" do
    users(:active_user).regenerate_verification_token
    get edit_user_password_path(users(:active_user), token: "does not match")

    assert_redirected_to new_session_path
  end

  test "should redirect to new_session_path when token is nil" do
    users(:active_user).regenerate_verification_token
    get edit_user_password_path(users(:active_user), token: nil)

    assert_redirected_to new_session_path
  end

  test "should update password for verified user" do
    users(:active_user).regenerate_verification_token
    put user_password_path(*password_params)

    assert_redirected_to new_session_path
    assert users(:active_user).reload.authenticated?("abcd1234"), "password should be changed"
    assert_predicate users(:active_user).verification_token, :blank?
  end

  test "should fail to update password for verified user when confirmation does not match" do
    users(:active_user).regenerate_verification_token
    put user_password_path(*password_params(confirmation: "not_the_same"))

    assert_response :success
    assert users(:active_user).reload.authenticated?(PASSWORD), "password should not be changed"
    assert_predicate users(:active_user).verification_token, :present?
  end

  test "should fail to update password for unverifed user" do
    users(:active_user).regenerate_verification_token
    put user_password_path(*password_params(token: "wrong_token"))

    assert_response :success
    assert users(:active_user).reload.authenticated?(PASSWORD), "password should not be changed"
    assert_predicate users(:active_user).verification_token, :present?
  end

  private

  def password_params(token: nil, confirmation: nil)
    [
      users(:active_user),
      {
        token: token || users(:active_user).verification_token,
        user:  { password: "abcd1234", password_confirmation: confirmation || "abcd1234" }
      }
    ]
  end
end
