module MinimalistAuthentication
  module Controller
    extend ActiveSupport::Concern

    included do
      # Lock down everything by default
      # use skip_before_action to open up specific actions
      before_action :authorization_required

      helper_method :current_user, :logged_in?, :authorized?
    end

    private

    def current_user
      @current_user ||= (get_user_from_session || MinimalistAuthentication.configuration.user_model.guest)
    end

    def get_user_from_session
      return unless session_user_id
      MinimalistAuthentication.configuration.user_model.active.find_by(id: session_user_id)
    end

    def session_user_id
      session[MinimalistAuthentication.configuration.session_key]
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
      store_location if request.method.to_s.downcase == "get" && !logged_in?
      redirect_to new_session_path
    end

    def store_location
      session["return_to"] = request.fullpath
    end

    def redirect_back_or_default(default)
      redirect_to(session.delete("return_to") || default)
    end
  end
end
