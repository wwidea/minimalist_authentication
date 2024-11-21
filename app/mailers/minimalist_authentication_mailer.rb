# frozen_string_literal: true

class MinimalistAuthenticationMailer < ApplicationMailer
  before_action { @user = params[:user] }
  after_action :mail_user

  def verify_email
    @verify_email_url = email_verification_url(token: @user.generate_token_for(:email_verification))
  end

  def update_password
    @edit_password_url = edit_password_url(token: @user.generate_token_for(:password_reset))
  end

  private

  def mail_user
    mail(to: @user.email)
  end
end
