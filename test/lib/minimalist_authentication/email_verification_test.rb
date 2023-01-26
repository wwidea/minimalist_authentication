require 'test_helper'

class EmailVerificationTest < ActiveSupport::TestCase
  test 'should verify users email address' do
    users(:active_user).regenerate_verification_token
    token = users(:active_user).verification_token

    assert users(:active_user).verify_email(token)
    assert users(:active_user).email_verified?
  end

  test 'should fail to verify users email address' do
    users(:legacy_user).regenerate_verification_token

    refute users(:legacy_user).verify_email('does_not_match')
    refute users(:legacy_user).email_verified?
  end
end
