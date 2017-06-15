require 'test_helper'

class AuthenticationTest < ActiveSupport::TestCase

  test "should return active user" do
    user = FactoryGirl.create(:user)
    assert_equal [user], User.active
  end

  test "should authenticate user" do
    user = FactoryGirl.create(:user)
    assert_equal user, User.authenticate(user.email, 'password')
  end

  test "should fail to authenticate when email is blank" do
    user = FactoryGirl.create(:user)
    assert_nil(User.authenticate('', 'password'))
  end

  test "should fail to authenticate when password is blank" do
    user = FactoryGirl.create(:user)
    assert_nil(User.authenticate(user.email, ''))
  end

  test "should fail to authenticate when user is not active" do
    user = FactoryGirl.create(:user, active: false)
    assert_nil(User.authenticate(user.email, 'password'))
  end

  test "should fail to authenticate for incorrect password" do
    user = FactoryGirl.create(:user)
    assert_nil(User.authenticate(user.email, 'incorrect_password'))
  end

  test "should create salt and encrypted_password for new user" do
    user = User.new(email: 'test@testing.com', password: 'testing')
    assert(user.save)
    assert_not_nil(user.salt)
    assert_not_nil(user.crypted_password)
    assert(user.authenticated?('testing'))
  end

  test "should update last_logged_in_at without updating updated_at timestamp" do
    user = FactoryGirl.create(:user, updated_at: 1.day.ago)
    updated_at = user.updated_at
    user.logged_in
    assert(user.updated_at == updated_at)
  end

  test "guest should be guest" do
    assert(User.guest.is_guest?)
  end

  test "should allow inactive user to pass validation without an email or password" do
    assert(User.new.valid?)
  end

  test "should fail validation for active user without email" do
    user = User.new(active: true)
    assert_equal(false, user.valid?)
    assert(user.errors[:email])
  end

  test "should fail validation for active user without password" do
    user = User.new(active: true)
    assert_equal(false, user.valid?)
    assert(user.errors[:password])
  end

  test "should use latest digest version for new users" do
    assert_equal(User::PREFERRED_DIGEST_VERSION,FactoryGirl.create(:user).using_digest_version)
  end

  test "should migrate legacy users to new digest version" do
    # Setup a user using the old digest version.
    # This wouldn't be necessary with fixtures.
    legacy_user = User.create(active: true, email: 'legacy@user.com', password: '123456', password_confirmation:'123456')
    legacy_user.password = nil
    legacy_user.salt = 'my_salt'
    legacy_user.crypted_password = User.secure_digest('my_password', 'my_salt', 1)
    legacy_user.using_digest_version = nil
    assert legacy_user.save
    assert_nil legacy_user.reload.using_digest_version
    assert_equal '86f156baf9e4868e6dcf910b65775efdeaa347d8', legacy_user.crypted_password

    # Ok, now we can finally do the test.
    legacy_crypted_password = legacy_user.crypted_password
    assert legacy_user.authenticated?('my_password')
    assert_equal Minimalist::Authentication::PREFERRED_DIGEST_VERSION, legacy_user.reload.using_digest_version
    assert_not_equal legacy_crypted_password, legacy_user.crypted_password
  end
end
