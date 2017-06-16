module Minimalist
  module TestHelper
    def login_as(user_fixture_name, password = 'password')
      post session_path, params: { user: { email: users(user_fixture_name).email, password: password } }
    end
    
    
    def current_user
      @current_user ||= (@request.session[:user_id] ? User.find(@request.session[:user_id]) : nil)
    end
  end
end
