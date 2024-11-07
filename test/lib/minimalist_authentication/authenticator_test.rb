# frozen_string_literal: true

require "test_helper"

class AuthenticatorTest < ActiveSupport::TestCase
  test "should authenticate user with email" do
    assert_equal users(:active_user), authenticated_user(email: users(:active_user).email, password: PASSWORD)
  end

  test "should authenticate user with username" do
    assert_equal users(:active_user), authenticated_user(username: users(:active_user).username, password: PASSWORD)
  end

  test "should fail to authenticate when params are empty" do
    assert_not authenticated_user({})
  end

  test "should fail to authenticate when field is missing" do
    assert_not authenticated_user(password: PASSWORD)
  end

  test "should fail to authenticate when email is blank" do
    assert_not authenticated_user(email: "", password: PASSWORD)
  end

  test "should fail to authenticate when password is blank" do
    assert_not authenticated_user(email: users(:active_user).email, password: "")
  end

  test "should fail to authenticate when user is not active" do
    users(:active_user).update_column(:active, false)

    assert_not authenticated_user(email: users(:active_user).email, password: PASSWORD)
  end

  test "should fail to authenticate with incorrect password" do
    assert_not authenticated_user(email: users(:active_user).email, password: "incorrect_password")
  end

  test "should return user for authenticated_user when authentication is successful" do
    assert_equal users(:active_user), authenticator.new(**parameters).authenticated_user
  end

  test "should return nil for authenticated_user when authentication fails" do
    assert_nil authenticator.new(**parameters(password: "incorrect_password")).authenticated_user
  end

  private

  def authenticated_user(params)
    authenticator.authenticated_user(params)
  end

  def authenticator
    MinimalistAuthentication::Authenticator
  end

  def parameters(password: PASSWORD)
    { field: "email", value: "active@example.com", password: }
  end
end
