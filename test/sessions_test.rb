require File.dirname(__FILE__) + '/test_helper'
require 'rails'

module MinimalistAuthentication
  class Application < Rails::Application
  end
end
MinimalistAuthentication::Application.initialize!

MinimalistAuthentication::Application.routes.draw do
  resource :session#, :only => [:new, :create, :destroy]
end

class ApplicationController < ActionController::Base
  include Minimalist::Authorization
end

class SessionsController < ApplicationController
  include Minimalist::Sessions
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