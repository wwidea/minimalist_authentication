# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
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
    assert_not User.new(password_hash: PASSWORD).authenticated?(PASSWORD)
  end

  test "should create password_hash for new user" do
    user = User.new(email: "test-new@testing.com", password: "testing")

    assert          user.save
    assert_not_nil  user.password_hash
    assert          user.authenticated?("testing")
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
    assert user.errors[:email]
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

  test "should allow an active user to have a duplicate email with an inactive user" do
    assert_predicate new_user(active: true, email: users(:inactive_user).email), :valid?
  end

  test "should not allow an active user to have a duplicate email with another active user" do
    assert_not new_user(email: users(:active_user).email).valid?
  end

  test "should allow an inactive user to have a duplicate email with another inactive user" do
    assert_predicate new_user(active: false, email: users(:inactive_user).email), :valid?
  end

  test "should update password_hash with increased cost" do
    increase_password_hash_cost(times: 3)

    assert_difference "users(:legacy_user).send(:password_object).cost" do
      assert users(:legacy_user).authenticated?(PASSWORD)
    end
  end

  test "should authenticate user during and after password_hash cost update" do
    increase_password_hash_cost(times: 4)

    assert users(:legacy_user).authenticated?(PASSWORD)
    assert users(:legacy_user).authenticated?(PASSWORD)
  end

  test "should skip update password_hash with increased cost when user is not valid" do
    increase_password_hash_cost(times: 1)
    users(:legacy_user).expects(:valid?).returns(false)

    assert_no_difference "users(:legacy_user).send(:password_object).cost" do
      assert users(:legacy_user).authenticated?(PASSWORD)
    end
  end

  private

  def increase_password_hash_cost(times:)
    MinimalistAuthentication::Password.expects(:cost).returns(BCrypt::Engine::MIN_COST + 1).times(times)
  end

  def new_user(active: true, email: "test@example.com")
    User.new(active:, email:, password: PASSWORD)
  end
end
