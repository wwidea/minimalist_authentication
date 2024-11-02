# frozen_string_literal: true

require "test_helper"

class AuthenticatorTest < ActiveSupport::TestCase
  PARAMETERS = { field: "email", value: "active@example.com", password: PASSWORD }.freeze

  test "should authenticate user with email" do
    assert_equal users(:active_user), authenticated_user(email: users(:active_user).email, password: PASSWORD)
  end

  test "should authenticate user with username" do
    assert_equal users(:active_user), authenticated_user(username: users(:active_user).username, password: PASSWORD)
  end

  test "should fail to authenticate when params are empty" do
    assert_not authenticated_user({})
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

  test "should fail to authenticate for incorrect password" do
    assert_not authenticated_user(email: users(:active_user).email, password: "incorrect_password")
  end

  test "should return user for authenticated_user when authentication is successful" do
    assert_equal users(:active_user), authenticator.new(**PARAMETERS).authenticated_user
  end

  test "should return nil for authenticated_user when authentication fails" do
    assert_nil authenticator.new(**PARAMETERS, password: "incorrect_password").authenticated_user
  end

  test "should return false for valid when any parameter argument is blank" do
    PARAMETERS.each_key do |key|
      assert_not authenticator.new(**PARAMETERS, key => "").valid?
    end
  end

  private

  def authenticated_user(params)
    authenticator.authenticated_user(params)
  end

  def authenticator
    MinimalistAuthentication::Authenticator
  end
end
