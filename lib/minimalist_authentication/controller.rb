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

    module ClassMethods
      def limit_creations
        rate_limit(
          to:     10,
          within: 3.minutes,
          only:   :create,
          with:   -> { redirect_to new_session_path, alert: t("limit_creations.alert") }
        )
      end
    end

    # Returns true if the user is logged in
    # Override this method in your controller to customize authorization
    def authorized?(_action = action_name, _resource = controller_name)
      logged_in?
    end

    # Returns the current user from the client application Current class
    def current_user
      ::Current.user
    end

    # Returns true if a current user is present, otherwise returns false
    def logged_in?
      current_user.present?
    end

    # Logs in a user by setting the session key and updating the Current user
    # Should only be called after a successful authentication
    def update_current_user(user)
      reset_session
      session[MinimalistAuthentication.session_key] = user.id
      ::Current.user = user
    end

    private

    def access_denied
      store_location if request.get? && !logged_in?
      redirect_to new_session_path
    end

    def authorization_required
      authorized? || access_denied
    end

    def find_session_user
      MinimalistAuthentication.user_model.find_enabled(session[MinimalistAuthentication.session_key])
    end

    def load_current_user
      Current.user = find_session_user
    end

    def store_location
      session["return_to"] = url_for(request.params.merge(format: :html, only_path: true))
    end
  end
end
