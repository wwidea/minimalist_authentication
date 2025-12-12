# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # account_setup token
  test "should invalidate account_setup token when password is created" do
    token = users(:new_user).generate_token_for(:account_setup)

    assert_equal users(:new_user), User.find_by_token_for(:account_setup, token)
    assert users(:new_user).update(password: "new_password")
    assert_not User.find_by_token_for(:account_setup, token)
  end

  # password_reset token
  test "should invalidate password_reset token when password is changed" do
    token = active_user.generate_token_for(:password_reset)

    assert_equal active_user, User.find_by_token_for(:password_reset, token)
    assert active_user.update(password: "new_password")
    assert_not User.find_by_token_for(:password_reset, token)
  end

  # validations
  test "validation for inactive user with empty attributes" do
    assert_predicate User.new(active: false), :valid?
  end

  test "validation for active user without email" do
    assert validated_user(active: true).errors.added?(:email, :blank)
  end

  test "validation for active user without password" do
    assert_not validated_user(active: true).errors.include?(:password)
  end

  test "validation for active user with blank password" do
    assert validated_user(active: true, password: "").errors.added?(:password, :blank)
  end

  test "validation for inactive user with blank password" do
    assert_not validated_user(active: false, password: "").errors.include?(:password)
  end

  test "should not allow a user to have a duplicate email with another user" do
    assert_predicate new_user(email: active_user.email), :invalid?
  end

  test "should not allow a user to have a password that matches their email" do
    user = new_user(password: "test@example.com")

    assert_predicate user, :invalid?
    assert_equal ["can not match email"], user.errors[:password]
  end

  test "should not allow a user to have a password that matches their username" do
    user = new_user(username: PASSWORD)

    assert_predicate user, :invalid?
    assert_equal ["can not match username"], user.errors[:password]
  end

  # active scope
  test "should return active users" do
    assert_equal users(:active_user, :legacy_user, :new_user).sort, User.active.sort
  end

  # find_enabled
  test "should return enabled user for find_enabled" do
    assert_equal active_user, User.find_enabled(identify(:active_user))
  end

  test "should return nil for find_enabled when user is not enabled" do
    User.any_instance.expects(:enabled).returns(nil)

    assert_nil User.find_enabled(identify(:active_user))
  end

  test "should return nil for find_enabled when user id is nil" do
    User.any_instance.expects(:find_by).never

    assert_nil User.find_enabled(nil)
  end

  test "should return nil for find_enabled when user id does not exist" do
    User.any_instance.expects(:find_by).never

    assert_nil User.find_enabled(42)
  end

  # enabled
  test "should return user for enabled when user is active" do
    assert_equal active_user, active_user.enabled
  end

  test "should return nil for enabled when user is inactive" do
    assert_nil users(:inactive_user).enabled
  end

  # enabled?
  test "should return true for enabled?" do
    assert_predicate active_user, :enabled?
  end

  test "should return false for enabled?" do
    assert_not users(:inactive_user).enabled?
  end

  # inactive?
  test "should return true for inactive?" do
    assert_predicate User.new(active: false), :inactive?
  end

  # inactive?
  test "should return false for inactive?" do
    assert_not_predicate User.new(active: true), :inactive?
  end

  # logged_in
  test "should update last_logged_in_at without updating updated_at timestamp" do
    updated_at = 1.day.ago
    active_user.update_column(:updated_at, updated_at)
    active_user.logged_in

    assert_equal updated_at.to_s, active_user.reload.updated_at.to_s
  end

  # password
  test "should create password_digest for new user" do
    user = User.new(email: "test-new@testing.com", password: PASSWORD)

    assert          user.save
    assert_not_nil  user.password_digest
    assert          user.authenticate(PASSWORD)
  end

  test "should not update password_digest when password is blank" do
    digest = active_user.password_digest
    active_user.password = ""

    assert active_user.save
    assert_equal digest, active_user.reload.password_digest
  end

  private

  def active_user
    users(:active_user)
  end

  def new_user(active: true, email: "test@example.com", password: PASSWORD, username: "test")
    User.new(active:, email:, password:, username:)
  end

  def validated_user(**)
    User.new(**, &:validate)
  end
end
