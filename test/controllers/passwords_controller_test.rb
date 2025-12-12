# frozen_string_literal: true

require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  NEW_PASSWORD = "abcdef123456"

  test "new with valid token" do
    get new_password_path(token: account_setup_token)
    assert_response :success
  end

  test "new with invalid token" do
    get new_password_path(token: password_reset_token)
    assert_redirected_to new_session_path
  end

  test "create with valid token" do
    post password_path(params(token: account_setup_token))
    assert_redirected_to new_session_path
    assert_password_changed new_user
    assert_predicate new_user, :email_verified?
  end

  test "create with invalid token" do
    post password_path(params(token: password_reset_token))
    assert_redirected_to new_session_path
    assert_not_predicate new_user.reload, :password_digest?
    assert_not_predicate new_user, :email_verified?
  end

  test "edit with valid token" do
    get edit_password_path(token: password_reset_token)
    assert_response :success
  end

  test "edit with invalid token" do
    get edit_password_path(token: account_setup_token)
    assert_redirected_to new_session_path
  end

  test "edit with nil token" do
    get edit_password_path(token: nil)
    assert_redirected_to new_session_path
  end

  test "update with valid token" do
    patch password_path(params)
    assert_redirected_to new_session_path
    assert_password_changed active_user
  end

  test "update with invalid token" do
    patch password_path(params(token: "wrong_token"))
    assert_redirected_to new_session_path
    assert_password_not_changed active_user
  end

  test "update with mismatched password confirmation" do
    patch password_path(params(password_confirmation: "not_the_same"))
    assert_response :unprocessable_content
    assert_password_not_changed active_user
  end

  private

  def account_setup_token
    new_user.generate_token_for(:account_setup)
  end

  def active_user
    users(:active_user)
  end

  def assert_password(user, password, message)
    assert user.reload.authenticate(password), message
  end

  def assert_password_changed(user)
    assert_password(user, NEW_PASSWORD, "password should be changed")
  end

  def assert_password_not_changed(user)
    assert_password(user, PASSWORD, "password should not be changed")
  end

  def params(token: password_reset_token, password_confirmation: NEW_PASSWORD)
    { token:, user: { password: NEW_PASSWORD, password_confirmation: } }
  end

  def password_reset_token
    active_user.generate_token_for(:password_reset)
  end

  def new_user
    users(:new_user)
  end
end
