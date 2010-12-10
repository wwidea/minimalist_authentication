require 'test_helper'

class AuthenticationTest < ActiveSupport::TestCase
  load_schema
  
  test "should not be able to set crypted_password through mass assignment" do
    user = Factory(:user)
    old_crypted_password = user.crypted_password
    user.update_attributes(:crypted_password => 'should not work')
    assert_equal(old_crypted_password, user.crypted_password)
  end
  
  test "should return active user" do
    user = Factory(:user)
    assert_equal([user], User.active)
  end
  
  test "should authenticate user" do
    user = Factory(:user)
    assert_equal(user, User.authenticate(user.email, 'password'))
  end
  
  test "should fail to authenticate when email is blank" do
    user = Factory(:user)
    assert_nil(User.authenticate('', 'password'))
  end
  
  test "should fail to authenticate when password is blank" do
    user = Factory(:user)
    assert_nil(User.authenticate(user.email, ''))
  end  
  
  test "should fail to authenticate when user is not active" do
    user = Factory(:user, :active => false)
    assert_nil(User.authenticate(user.email, 'password'))
  end
  
  test "should fail to authenticate for incorrect password" do
    user = Factory(:user)
    assert_nil(User.authenticate(user.email, 'incorrect_password'))
  end
  
  test "should create salt and encrypted_password for new user" do
    user = User.new(:email => 'test@testing.com', :password => 'testing')
    assert(user.save)
    assert_not_nil(user.salt)
    assert_not_nil(user.crypted_password)
    assert(user.authenticated?('testing'))
  end
  
  test "should update last_logged_in_at without updating updated_at timestamp" do
    user = Factory(:user, :updated_at => 1.day.ago)
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
    user = User.new(:active => true)
    assert_equal(false, user.valid?)
    assert(user.errors.on(:email))
  end
  
  test "should fail validation for active user without password" do
    user = User.new(:active => true)
    assert_equal(false, user.valid?)
    assert(user.errors.on(:password))
  end
end
