module Minimalist
  module Sessions
    extend ActiveSupport::Concern

    included do
      skip_before_action :authorization_required,     only: %i(new create)
      skip_before_action :verify_authenticity_token,  only: %i(create destroy)
    end

    def new
      @user = ::User.new
    end

    def create
      if authenticated_user
        scrub_session!
        authenticated_user.logged_in
        session[:user_id] = authenticated_user.id
        after_authentication_success
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

    def authenticated_user
      @authenticated_user ||= ::User.authenticate(user_params)
    end

    def user_params
      @user_params ||= params.require(:user).permit(:email, :username, :password)
    end

    def after_authentication_success
      redirect_back_or_default(login_redirect_to)
    end

    def after_authentication_failure
      flash.now[:alert] = "Couldn't log you in as '#{user_params[:email] || user_params[:username]}'"
      render :new
    end

    def scrub_session!
      (session.keys - %w(session_id _csrf_token return_to)).each do |key|
        session.delete(key)
      end
    end

    def login_redirect_to
      root_path
    end

    def logout_redirect_to
      new_session_path
    end
  end
end
