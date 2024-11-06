# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # password_reset token
  test "should invalidate password_reset token when password is changed" do
    token = users(:active_user).generate_token_for(:password_reset)

    assert_equal users(:active_user), User.find_by_token_for(:password_reset, token)
    assert users(:active_user).update(password: "new_password")
    assert_not User.find_by_token_for(:password_reset, token)
  end

  # scopes
  test "should return active users" do
    assert_equal users(:active_user, :legacy_user).sort, User.active.sort
  end

  test "should return inactive users" do
    assert_equal [users(:inactive_user).email], User.inactive.map(&:email)
  end

  test "should return true for inactive?" do
    assert_predicate User.new, :inactive?
  end

  test "should return false for inactive?" do
    assert_not User.new(active: true).inactive?
  end

  test "should gracefully fail to authenticate to an invalid password hash" do
    assert_not User.new(password_digest: PASSWORD).authenticated?(PASSWORD)
  end

  test "should create password_digest for new user" do
    user = User.new(email: "test-new@testing.com", password: "testing")

    assert          user.save
    assert_not_nil  user.password_digest
    assert          user.authenticated?("testing")
  end

  test "should not update password_digest when password is blank" do
    digest = users(:active_user).password_digest
    users(:active_user).password = ""

    assert users(:active_user).save
    assert_equal digest, users(:active_user).reload.password_digest
  end

  test "should update last_logged_in_at without updating updated_at timestamp" do
    updated_at = 1.day.ago
    users(:active_user).update_column(:updated_at, updated_at)
    users(:active_user).logged_in

    assert_equal updated_at.to_s, users(:active_user).reload.updated_at.to_s
  end

  test "guest should be guest" do
    assert_predicate User.guest, :guest?
  end

  test "should not be able to modify guest user" do
    assert_raise RuntimeError do
      User.guest.email = "test@testing.com"
    end
  end

  test "should allow inactive user to pass validation without an email or password" do
    assert_predicate User.new, :valid?
  end

  test "should fail validation for active user without email" do
    user = User.new(active: true)

    assert_not user.valid?
    assert_equal ["can't be blank"], user.errors[:email]
  end

  test "should fail validation for active user without password" do
    user = User.new(active: true)

    assert_not user.valid?
    assert user.errors.key?(:password)
  end

  test "should pass validation for a user with a password hash and a blank password" do
    user = users(:active_user)
    user.password = ""

    assert_predicate user, :valid?
  end

  test "should fail validation for a user with blank password and password_required true" do
    user = users(:active_user)
    user.password_required = true
    user.password = ""

    assert_not user.valid?
    assert user.errors.key?(:password)
  end

  test "should not allow a user to have a duplicate email with another user" do
    assert_not new_user(email: users(:active_user).email).valid?
  end

  test "should not allow a user to have a password that matches their email" do
    user = new_user(password: "test@example.com")

    assert_not user.valid?
    assert_equal ["can not match email"], user.errors[:password]
  end

  test "should not allow a user to have a password that matches their username" do
    user = new_user(username: PASSWORD)

    assert_not user.valid?
    assert_equal ["can not match username"], user.errors[:password]
  end

  test "should return true for password?" do
    assert_predicate User.new(password: "testing"), :password?
  end

  test "should return false for password?" do
    assert_not_predicate User.new(password: ""), :password?
  end

  private

  def new_user(active: true, email: "test@example.com", password: PASSWORD, username: "test")
    User.new(active:, email:, password:, username:)
  end
end
