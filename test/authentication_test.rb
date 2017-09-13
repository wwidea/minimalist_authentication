require 'test_helper'

class AuthenticationTest < ActiveSupport::TestCase

  test "should return active user" do
    assert_equal users(:legacy_user, :active_user), User.active.order(:email)
  end

  test "should authenticate user with email" do
    assert_equal users(:active_user), User.authenticate(email: users(:active_user).email, password: 'password')
  end

  test "should authenticate user with username" do
    assert_equal users(:active_user), User.authenticate(username: users(:active_user).username, password: 'password')
  end

  test "should fail to authenticate when email is blank" do
    assert_nil User.authenticate(email: '', password: 'password')
  end

  test "should fail to authenticate when password is blank" do
    assert_nil User.authenticate(email: users(:active_user).email, password: '')
  end

  test "should fail to authenticate when user is not active" do
    users(:active_user).update_column(:active, false)
    assert_nil User.authenticate(email: users(:active_user).email, password: 'password')
  end

  test "should fail to authenticate for incorrect password" do
    assert_nil User.authenticate(email: users(:active_user).email, password: 'incorrect_password')
  end

  test "should create salt and encrypted_password for new user" do
    user = User.new(email: 'test-new@testing.com', password: 'testing')
    assert          user.save
    assert_not_nil  user.salt
    assert_not_nil  user.crypted_password
    assert          user.authenticated?('testing')
  end

  test "should update last_logged_in_at without updating updated_at timestamp" do
    updated_at = 1.day.ago
    users(:active_user).update_column(:updated_at, updated_at)
    users(:active_user).logged_in
    assert_equal updated_at.to_s, users(:active_user).reload.updated_at.to_s
  end

  test "guest should be guest" do
    assert User.guest.is_guest?
  end

  test "should allow inactive user to pass validation without an email or password" do
    assert User.new.valid?
  end

  test "should fail validation for active user without email" do
    user = User.new(active: true)
    refute user.valid?
    assert user.errors[:email]
  end

  test "should fail validation for active user without password" do
    user = User.new(active: true)
    refute user.valid?
    assert user.errors[:password]
  end

  test "should migrate legacy user to new salt" do
    users(:legacy_user).expects(:salt_cost).returns(0) do
      assert users(:legacy_user).authenticated?('my_password')
      assert users(:legacy_user).saved_changes.has_key?(:crypted_password)
      assert users(:legacy_user).saved_changes.has_key?(:salt)
    end

    assert users(:legacy_user).authenticated?('my_password'), 'authenticated? failed after encryption update'
  end
end
