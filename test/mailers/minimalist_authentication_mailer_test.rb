require 'test_helper'

class MinimalistAuthenticationMailerTest < ActionMailer::TestCase
  test 'verify_email' do
    users(:legacy_user).regenerate_verification_token
    mail = MinimalistAuthenticationMailer.verify_email(users(:legacy_user))

    assert_equal "Email Address Verification",            mail.subject
    assert_equal ["legacy@example.com"],                  mail.to
    assert_match users(:legacy_user).verification_token,  mail.body.encoded
  end

  test 'update_password' do
    users(:active_user).regenerate_verification_token
    mail = MinimalistAuthenticationMailer.update_password(users(:active_user))

    assert_equal "Update Password",                       mail.subject
    assert_equal ["active@example.com"],                  mail.to
    assert_match users(:active_user).verification_token,  mail.body.encoded
  end
end
