# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  skip_before_action :authorization_required

  layout "sessions"

  # Limit create requests by ip address
  limit_creations

  # Password reset request form
  def new
    # new.html.erb
  end

  # Send a password update link to users with a verified email
  def create
    if email_valid?
      send_update_password_email(user)

      # Always display notice to prevent leaking user emails
      redirect_to new_session_path, notice: t(".notice", email:)
    else
      flash.now.alert = t(".alert")
      render :new, status: :unprocessable_content
    end
  end

  private

  def email
    params.dig(:user, :email)
  end

  def send_update_password_email(user)
    MinimalistAuthenticationMailer.with(user:).update_password.deliver_now if user
  end

  def user
    MinimalistAuthentication.user_model.find_enabled_by(email:)
  end

  def email_valid?
    URI::MailTo::EMAIL_REGEXP.match?(email)
  end
end
