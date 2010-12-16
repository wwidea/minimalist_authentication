module Minimalist
  module TestHelper
    # Sets the current user in the session from the user fixtures.
    def login_as(user)
      @request.session[:user_id] = user ? users(user).id : nil
    end
    
    def current_user
      @current_user ||= User.find(@request.session[:user_id])
    end
  end
end