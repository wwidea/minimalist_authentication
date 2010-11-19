require 'test_helper'

class AuthorizationTest < ActiveSupport::TestCase
  def AuthorizationTest.helper_method(*args); end
  include Minimalist::Authorization
  
  test "should return guest for current_user" do
    assert_equal('guest', current_user.email)
  end
  
  test "should return logged_in user for current_user" do
    user = Factory(:user)
    session[:user_id] = user.id
    assert_equal(user, current_user)
  end
  
  test "should pass authorization" do
    user = Factory(:user)
    session[:user_id] = user.id
    assert(authorization_required)
  end
  
  test "should fail authorization" do
    assert_equal(new_session_path, authorization_required)
  end
  
  test "should store location" do
    store_location
    assert_equal(request.request_uri, session[:return_to])
  end
  
  test "should redirect to stored location" do
    store_location
    redirect_back_or_default('/')
    assert_equal(request.request_uri, redirect_to)
  end
  
  test "should redirect to stored location only once" do
    store_location
    redirect_back_or_default('/')
    assert_equal(request.request_uri, redirect_to)
    redirect_back_or_default('/')
    assert_equal('/', redirect_to)
  end
  
  test "should redirect to default" do
    redirect_back_or_default('/')
    assert_equal('/', redirect_to)
  end
  
  #######
  private
  #######
  
  def redirect_to(path = nil)
    @redirect_to = path if path
    return @redirect_to
  end
  
  def session; @session ||= Hash.new; end
  
  def action_name; nil; end
  def controller_name; nil; end
  def new_session_path; '/session/new'; end
  
  def request
    (Class.new do
      def method
        :get
      end
      
      def request_uri
        'http://www.example.com'
      end
    end).new
  end
end
