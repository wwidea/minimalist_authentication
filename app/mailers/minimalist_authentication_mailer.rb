# frozen_string_literal: true

class MinimalistAuthenticationMailer < ApplicationMailer
  def verify_email(user)
    @verify_email_link = email_verification_url(token: user.verification_token)
    send_to(user, "Email Address Verification")
  end

  def update_password(user)
    @edit_password_link = edit_user_password_url(user, token: user.verification_token)
    send_to(user, "Update Password")
  end

  private

  def send_to(user, subject)
    @user = user
    mail to: @user.email, subject: prefixed_subject(subject)
  end

  def prefixed_subject(subject)
    "#{MinimalistAuthentication.configuration.email_prefix} #{subject}"
  end
end
