require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should return active users" do
    assert_equal users(:active_user, :legacy_user).sort, User.active.sort
  end

  test "should return inactive users" do
    assert_equal [users(:inactive_user).email], User.inactive.map(&:email)
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

  test "should return true for active?" do
    assert User.new(active: true).active?
  end

  test "should return false for active?" do
    refute User.new.active?
  end

  test "should return true for inactive?" do
    assert User.new.inactive?
  end

  test "should return false for inactive?" do
    refute User.new(active: true).inactive?
  end

  test "should gracefully fail to authenticate to an invalid password hash" do
    refute User.new(password_hash: 'password').authenticated?('password')
  end

  test "should create password_hash for new user" do
    user = User.new(email: 'test-new@testing.com', password: 'testing')
    assert          user.save
    assert_not_nil  user.password_hash
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

  test "should not be able to moidfy guest user" do
    assert_raise RuntimeError do
      User.guest.email = 'test@testing.com'
    end
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
    assert user.errors.has_key?(:password)
  end

  test "should pass validation for a user with a password hash and a blank password" do
    user = users(:active_user)
    user.password = ''
    assert user.valid?
  end

  test "should fail validation for a user with blank password and password_required true" do
    user = users(:active_user)
    user.password_required = true
    user.password = ''
    refute user.valid?
    assert user.errors.has_key?(:password)
  end

  test "should allow an active user to have a dupliate email with an inactive user" do
    assert new_user(active: true, email: users(:inactive_user).email).valid?
  end

  test "shold not allow an active user to have a duplicate email with another active user" do
    assert_not new_user(email: users(:active_user).email).valid?
  end

  test "should allow an inactive user to have a dupliate email with another inactive user" do
    assert new_user(active: false, email: users(:inactive_user).email).valid?
  end

  test "should migrate legacy user to new salt" do
    new_cost = MinimalistAuthentication::Password.cost + 1
    MinimalistAuthentication::Password.expects(:cost).returns(new_cost).times(4)

    assert_equal (new_cost - 1), users(:legacy_user).send(:password_object).cost
    assert users(:legacy_user).authenticated?('password'), 'authenticated? failed during encryption update'
    assert users(:legacy_user).saved_changes.has_key?(:password_hash)

    assert users(:legacy_user).authenticated?('password'), 'authenticated? failed after encryption update'
    assert_equal new_cost, users(:legacy_user).send(:password_object).cost
  end

  private

  def new_user(active: true, email: 'test@example.com')
    User.new(active: active, email: email, password: 'password')
  end
end
