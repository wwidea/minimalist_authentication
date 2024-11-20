# frozen_string_literal: true

require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  NEW_PASSWORD = "abcdef123456"

  test "should get edit for verified user" do
    get edit_password_path(token: password_reset_token)

    assert_response :success
  end

  test "should fail to get edit for unverified user" do
    get edit_password_path(token: "does not match")

    assert_redirected_to new_session_path
  end

  test "should redirect to new_session_path when token is nil" do
    get edit_password_path(token: nil)

    assert_redirected_to new_session_path
  end

  test "should update password for verified user" do
    put password_path(password_params)

    assert_redirected_to new_session_path
    assert user.reload.authenticate(NEW_PASSWORD), "password should be changed"
  end

  test "should fail to update password for verified user when confirmation does not match" do
    put password_path(password_params(password_confirmation: "not_the_same"))

    assert_response :unprocessable_entity
    assert user.reload.authenticate(PASSWORD), "password should be unchanged"
  end

  test "should fail to update password for unverified user" do
    put password_path(password_params(token: "wrong_token"))

    assert_redirected_to new_session_path
    assert user.reload.authenticate(PASSWORD), "password should not be changed"
  end

  private

  def password_params(token: password_reset_token, password_confirmation: NEW_PASSWORD)
    { token:, user: { password: NEW_PASSWORD, password_confirmation: } }
  end

  def password_reset_token
    user.generate_token_for(:password_reset)
  end

  def user
    users(:active_user)
  end
end
