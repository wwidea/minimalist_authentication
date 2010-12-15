module Minimalist
  module Sessions
    def self.included( base )
      base.class_eval do
        include InstanceMethods
        append_view_path File.join(File.dirname(__FILE__), '..', '/app/views')
      end
    end
    
    module InstanceMethods
      def show
        redirect_to new_session_path
      end
      
      def new
      end

      def create
        if user = User.authenticate(params[:email], params[:password])
          user.logged_in
          session[:user_id] = user.id
          after_authentication(user)
          redirect_back_or_default(login_redirect_to(user))
          return
        else
          after_authentication_failure
          flash.now[:error] = "Couldn't log you in as '#{params[:email]}'"
          render :action => 'new'
        end
      end

      def destroy
        session[:user_id] = nil
        flash[:notice] = "You have been logged out."
        redirect_to logout_redirect_to
      end
      
      #######
      private
      #######
      
      def login_redirect_to(user)
        '/'
      end
      
      def logout_redirect_to
        '/'
      end
      
      def after_authentication(user)
        # overide in application
      end
      
      def after_authentication_failure(user)
        # overide in application
      end
    end
  end
end