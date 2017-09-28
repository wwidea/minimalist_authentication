class PasswordResetsController < ApplicationController
  skip_before_action :authorization_required

  # Form for user to request a password reset
  def new
    @user = MinimalistAuthentication.configuration.user_model.new
  end

  # Send a password update link to users with a verified email
  def create
    if user
      user.regenerate_verification_token
      MinimalistAuthenticationMailer.update_password(user).deliver_now
    end
    # always display notice even if the user was not found to prevent leaking user emails
    redirect_to new_session_path, notice: "Password reset instructions were mailed to #{email_params[:email]}"
  end

  private

  def user
    @user ||= MinimalistAuthentication.configuration.user_model.active.email_verified.find_by(email_params)
  end

  def email_params
    params.require(:user).permit(:email)
  end
end
