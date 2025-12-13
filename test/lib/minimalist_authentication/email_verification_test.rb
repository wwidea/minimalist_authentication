# frozen_string_literal: true

require "test_helper"

class EmailVerificationTest < ActiveSupport::TestCase
  # email_verification token
  test "should invalidate email verification token when email is changed" do
    token = users(:active_user).generate_token_for(:email_verification)

    assert_equal users(:active_user), User.find_by_token_for(:email_verification, token)
    assert users(:active_user).update(email: "testing@example.com")
    assert_not User.find_by_token_for(:password_reset, token)
  end

  # clear_email_verification
  test "should clear email verification when email is changed" do
    assert_predicate users(:active_user).email_verified_at, :present?
    users(:active_user).update(email: "testing@example.com")

    assert_nil users(:active_user).reload.email_verified_at
  end

  # find_by_verified_email
  test "should find user by verified email" do
    assert_equal users(:active_user), User.find_by_verified_email(email: users(:active_user).email)
  end

  test "should not find inactive user by verified email" do
    users(:active_user).update_column(:active, false)

    assert_nil User.find_by_verified_email(email: users(:active_user).email)
  end

  test "should not find user by unverified email" do
    assert_nil User.find_by_verified_email(email: users(:legacy_user).email)
  end

  # verified_update
  test "verified_update with new password" do
    assert users(:new_user).verified_update(password: NEW_PASSWORD)
    assert users(:new_user).authenticate(NEW_PASSWORD)
    assert_predicate users(:new_user), :email_verified?
  end

  # verify_email_with
  test "should verify users email address" do
    token = users(:legacy_user).generate_token_for(:email_verification)

    assert users(:legacy_user).verify_email_with(token)
    assert_predicate users(:legacy_user), :email_verified?
  end

  test "should fail to verify users email address with invalid token" do
    assert_not users(:legacy_user).verify_email_with("does_not_match")
    assert_not users(:legacy_user).email_verified?
  end

  test "should fail to verify users email address with another users token" do
    token = users(:active_user).generate_token_for(:email_verification)

    assert_not users(:legacy_user).verify_email_with(token)
    assert_not_predicate users(:legacy_user), :email_verified?
  end
end
