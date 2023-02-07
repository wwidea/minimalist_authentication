class PasswordResetsController < ApplicationController
  skip_before_action :authorization_required

  layout "sessions"

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
    redirect_to new_session_path, notice: "Password reset instructions were mailed to #{email}"
  end

  private

  def user
    return unless URI::MailTo::EMAIL_REGEXP.match?(email)
    @user ||= MinimalistAuthentication.configuration.user_model.active.email_verified.find_by(email: email)
  end

  def email
    params.require(:user).fetch(:email)
  end
end
