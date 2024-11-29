# frozen_string_literal: true

module MinimalistAuthentication
  module Controller
    extend ActiveSupport::Concern

    included do
      # Loads the user object from the session and assigns it to Current.user
      before_action :load_current_user

      # Requires an authorized user for all actions
      # Use skip_before_action to allow access to specific actions
      before_action :authorization_required

      helper MinimalistAuthentication::ApplicationHelper

      helper_method :current_user, :logged_in?, :authorized?
    end

    private

    def access_denied
      store_location if request.get? && !logged_in?
      redirect_to new_session_path
    end

    def authorization_required
      authorized? || access_denied
    end

    def authorized?(_action = action_name, _resource = controller_name)
      logged_in?
    end

    def current_user
      Current.user
    end

    def find_session_user
      MinimalistAuthentication.user_model.find_enabled(session[MinimalistAuthentication.session_key])
    end

    def load_current_user
      Current.user = find_session_user
    end

    def logged_in?
      Current.user.present?
    end

    def store_location
      session["return_to"] = url_for(request.params.merge(format: :html, only_path: true))
    end

    def update_current_user(user)
      reset_session
      session[MinimalistAuthentication.session_key] = user.id
      Current.user = user
    end
  end
end
