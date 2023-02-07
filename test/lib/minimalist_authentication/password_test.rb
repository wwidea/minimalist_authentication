# frozen_string_literal: true

require "test_helper"

class PasswordTest < ActiveSupport::TestCase
  test "should create password hash" do
    assert hashed_password
  end

  test "should return NullPassword for invalid hash" do
    assert_kind_of(
      MinimalistAuthentication::NullPassword,
      MinimalistAuthentication::Password.new("").bcrypt_password
    )
  end

  test "should return false for stale?" do
    refute hashed_password.stale?
  end

  test "should return true for stale?" do
    password = hashed_password
    password.expects(:cost).returns(0)
    assert password.stale?
  end

  private

  def hashed_password
    MinimalistAuthentication::Password.create("testing")
  end
end
