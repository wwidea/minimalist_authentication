require "test_helper"

class MergePasswordHashTest < ActiveSupport::TestCase
  def setup
    password_hash = MinimalistAuthentication::Password.create("password")

    users(:legacy_user).update_columns(
      using_digest_version: 3,
      crypted_password:     password_hash.checksum,
      salt:                 password_hash.salt,
      password_hash:        nil
    )
  end

  test "should run merge password hash" do
    assert_difference "User.where(password_hash: nil).count", -1 do
      assert MinimalistAuthentication::Conversions::MergePasswordHash.run!
    end
  end

  test "should mmerge password hash" do
    MinimalistAuthentication::Conversions::MergePasswordHash.new(users(:legacy_user)).update!
    assert BCrypt::Password.new(users(:legacy_user).reload[:password_hash]) == "password"
  end
end
