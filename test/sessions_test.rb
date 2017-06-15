require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create session" do
    user = FactoryGirl.create(:user)
    post :create, email: 'test@testing.com', password: 'password'
    assert_equal(user.id, session[:user_id])
    assert_redirected_to '/'
  end
  
  test "should fail to create session" do
    user = FactoryGirl.create(:user)
    post :create, email: 'test@testing.com', password: 'wrong_password'
    assert_nil(session[:user_id])
    assert_response :success
  end
  
  test "should destroy session" do
    @request.session[:user_id] = 1
    delete :destroy
    assert_nil(session[:user_id])
    assert_redirected_to '/'
  end
end