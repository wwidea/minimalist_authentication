require 'test_helper'
require 'action_controller'
require 'action_controller/test_process'
ActionController::Routing::Routes.draw do |map|
  map.resource :session
end

class ApplicationController < ActionController::Base
  include Minimalist::Authorization
end

class SessionsController < ApplicationController
  include Minimalist::Sessions
end

ActionController::Routing::Routes.draw do |map|
  map.resource :session, :only => [:new, :create, :destroy]
end

class SessionsControllerTest < ActionController::TestCase
  load_schema
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create session" do
    user = Factory(:user)
    post :create, :email => 'test@testing.com', :password => 'password'
    assert_equal(user.id, session[:user_id])
    assert_redirected_to '/'
  end
  
  test "should fail to create session" do
    user = Factory(:user)
    post :create, :email => 'test@testing.com', :password => 'wrong_password'
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