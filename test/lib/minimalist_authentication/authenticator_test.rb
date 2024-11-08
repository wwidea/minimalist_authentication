# frozen_string_literal: true

require "test_helper"

class AuthenticatorTest < ActiveSupport::TestCase
  # MinimalistAuthentication::Authenticator.authenticate
  test "should authenticate user with email" do
    assert_equal users(:active_user), authenticate(email: users(:active_user).email, password: PASSWORD)
  end

  test "should authenticate user with username" do
    assert_equal users(:active_user), authenticate(username: users(:active_user).username, password: PASSWORD)
  end

  test "should fail to authenticate when params are empty" do
    assert_not authenticate({})
  end

  test "should fail to authenticate when field is missing" do
    assert_not authenticate(password: PASSWORD)
  end

  test "should fail to authenticate when email is blank" do
    assert_not authenticate(email: "", password: PASSWORD)
  end

  test "should fail to authenticate when password is blank" do
    assert_not authenticate(email: users(:active_user).email, password: "")
  end

  test "should fail to authenticate when user is not active" do
    users(:active_user).update_column(:active, false)

    assert_not authenticate(email: users(:active_user).email, password: PASSWORD)
  end

  test "should fail to authenticate with incorrect password" do
    assert_not authenticate(email: users(:active_user).email, password: "incorrect_password")
  end

  # authenticated_user
  test "should return user for authenticated_user when authentication is successful" do
    assert_equal users(:active_user), authenticated_user
  end

  test "should return nil for authenticated_user when authentication fails" do
    assert_nil authenticated_user(password: "incorrect_password")
  end

  test "should return nil for authenticated_user when user is not enabled" do
    User.any_instance.expects(:enabled).returns(nil)

    assert_nil authenticated_user
  end

  test "should return nil for authenticated_user when user password is blank without calling authenticate_by" do
    User.any_instance.expects(:authenticate_by).never

    assert_nil authenticated_user(password: "")
  end

  private

  def authenticate(params)
    MinimalistAuthentication::Authenticator.authenticate(params)
  end

  def authenticated_user(password: PASSWORD)
    MinimalistAuthentication::Authenticator.new(
      field:    "email",
      value:    "active@example.com",
      password:
    ).authenticated_user
  end
end
