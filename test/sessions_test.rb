require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  include Minimalist::TestHelper
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create session" do
    post :create, params: { user: { email: 'test@testing.com', password: 'password' } }
    assert_equal users(:active_user).id, session[:user_id]
    assert_redirected_to '/'
  end
  
  test "should fail to create session" do
    post :create, params: { user: { email: 'test@testing.com', password: 'wrong_password' } }
    assert_nil session[:user_id]
    assert_response :success
  end
  
  test "should destroy session" do
    login_as :active_user
    delete :destroy
    assert_nil session[:user_id]
    assert_redirected_to '/'
  end
end
