module Minimalist
  module Authorization
    def self.included( base )
      base.class_eval do
        include InstanceMethods
        
        helper_method :current_user
      end
    end
    
    module InstanceMethods
      #######
      private
      #######

      def current_user
        @current_user ||= (get_user_from_session || User.guest)
      end

      def get_user_from_session
        User.find_by_id(session[:user_id]) if session[:user_id]
      end

      def authorization_required
        authorized? || access_denied
      end

      def authorized?(action = action_name, resource = controller_name)
        logged_in?
      end

      def logged_in?
        !current_user.is_guest?
      end

      def access_denied
        store_location
        redirect_to new_session_path
      end

      def store_location
        session[:return_to] = request.request_uri
      end

      def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
      end
    end
  end
end