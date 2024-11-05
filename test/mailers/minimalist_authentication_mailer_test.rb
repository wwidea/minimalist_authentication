# frozen_string_literal: true

require "test_helper"

class MinimalistAuthenticationMailerTest < ActionMailer::TestCase
  test "verify_email" do
    users(:legacy_user).regenerate_verification_token
    mail = mailer_with(users(:legacy_user)).verify_email

    assert_equal "Email Address Verification",            mail.subject
    assert_equal ["legacy@example.com"],                  mail.to
    assert_match users(:legacy_user).verification_token,  mail.body.encoded
  end

  test "update_password" do
    users(:active_user).regenerate_verification_token
    mail = mailer_with(users(:active_user)).update_password

    assert_equal "Update Password",                       mail.subject
    assert_equal ["active@example.com"],                  mail.to
    assert_match users(:active_user).verification_token,  mail.body.encoded
  end

  private

  def mailer_with(user)
    MinimalistAuthenticationMailer.with(user: user)
  end
end
