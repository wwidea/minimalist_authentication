# frozen_string_literal: true

module MinimalistAuthentication
  module Sessions
    extend ActiveSupport::Concern

    included do
      # URL to redirect to after successful login
      attr_accessor :return_to

      skip_before_action  :authorization_required,    only: %i[new create]
      before_action       :redirect_logged_in_users,  only: :new
    end

    def new
      user
    end

    def create
      if authenticated_user
        log_in_user
        set_or_verify_email || after_authentication_success
      else
        after_authentication_failure
      end
    end

    def destroy
      reset_session
      clear_site_data
      redirect_to logout_redirect_to, notice: t(".notice"), status: :see_other
    end

    private

    # Sets a “Clear-Site-Data” header to clear the browser cache.
    def clear_site_data
      response.headers["Clear-Site-Data"] = '"cache","storage"'
    end

    def user
      @user ||= MinimalistAuthentication.configuration.user_model.new
    end

    def authenticated_user
      @authenticated_user ||= MinimalistAuthentication::Authenticator.authenticate(user_params)
    end

    def log_in_user
      self.return_to = session["return_to"]
      update_current_user(authenticated_user)
      authenticated_user.logged_in
    end

    def user_params
      @user_params ||= params.fetch(:user, {}).permit(:email, :username, :password)
    end

    def set_or_verify_email
      if authenticated_user.needs_email_set?
        redirect_to edit_email_path
      elsif authenticated_user.needs_email_verification? && !attempting_to_verify?
        redirect_to new_email_verification_path
      else
        false
      end
    end

    def redirect_logged_in_users
      redirect_to(login_redirect_to) if logged_in?
    end

    def after_authentication_success
      redirect_to return_to || login_redirect_to
    end

    def attempting_to_verify?
      # check if user is attempting to verify their email
      session["return_to"].to_s[/token/]
    end

    def after_authentication_failure
      flash.now.alert = t(".alert", identifier:)
      user
      render :new, status: :unprocessable_entity
    end

    def identifier
      user_params.values_at(*MinimalistAuthentication::Authenticator::LOGIN_FIELDS).compact.first
    end

    def login_redirect_to
      send(MinimalistAuthentication.configuration.login_redirect_path)
    end

    def logout_redirect_to
      send(MinimalistAuthentication.configuration.logout_redirect_path)
    end
  end
end
