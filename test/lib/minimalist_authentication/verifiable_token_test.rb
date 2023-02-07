# frozen_string_literal: true

require "test_helper"

class VerifiableTokenTest < ActiveSupport::TestCase
  test "should regenerate_verification_token" do
    assert users(:active_user).regenerate_verification_token
    assert users(:active_user).verification_token_valid?
  end

  test "should not have valid verification_token" do
    assert_not users(:active_user).verification_token_valid?
  end
end
