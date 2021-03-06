module MinimalistAuthentication
  module Sessions
    extend ActiveSupport::Concern

    included do
      skip_before_action  :authorization_required,    only: %i(new create)
      before_action       :redirect_logged_in_users,  only: :new
    end

    def new
      new_user
    end

    def create
      if authenticated_user
        scrub_session!
        authenticated_user.logged_in
        session[MinimalistAuthentication.configuration.session_key] = authenticated_user.id
        set_or_verify_email || after_authentication_success
        return
      else
        after_authentication_failure
      end
    end

    def destroy
      scrub_session!
      flash[:notice] = "You have been logged out."
      redirect_to logout_redirect_to
    end

    private

    def new_user
      @user ||= MinimalistAuthentication.configuration.user_model.new
    end

    def authenticated_user
      @authenticated_user ||= MinimalistAuthentication.configuration.user_model.authenticate(user_params)
    end

    def user_params
      @user_params ||= params.require(:user).permit(:email, :username, :password)
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
      redirect_back_or_default(login_redirect_to)
    end

    def attempting_to_verify?
      # check if user is attpting to verify their email
      session['return_to'].to_s[/token/]
    end

    def after_authentication_failure
      flash.now[:alert] = "Couldn't log you in as '#{user_params[:email] || user_params[:username]}'"
      new_user
      render :new
    end

    def scrub_session!
      (session.keys - %w(session_id return_to)).each do |key|
        session.delete(key)
      end
    end

    def login_redirect_to
      send(MinimalistAuthentication.configuration.login_redirect_path)
    end

    def logout_redirect_to
      send(MinimalistAuthentication.configuration.logout_redirect_path)
    end
  end
end
