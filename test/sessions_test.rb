require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  include Minimalist::TestHelper
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create session" do
    user = FactoryGirl.create(:user)
    post :create, params: { user: { email: 'test@testing.com', password: 'password' } }
    assert_equal user.id, session[:user_id]
    assert_redirected_to '/'
  end
  
  test "should fail to create session" do
    post :create, params: { user: { email: 'test@testing.com', password: 'wrong_password' } }
    assert_nil session[:user_id]
    assert_response :success
  end
  
  test "should destroy session" do
    login_as FactoryGirl.create(:user)
    delete :destroy
    assert_nil session[:user_id]
    assert_redirected_to '/'
  end
  
  private
  
  # make factory user availalbe like a fixure user
  def users(user)
    user
  end
end
