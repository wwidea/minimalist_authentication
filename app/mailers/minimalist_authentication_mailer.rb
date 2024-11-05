# frozen_string_literal: true

class MinimalistAuthenticationMailer < ApplicationMailer
  before_action { @user = params[:user] }
  after_action :mail_user

  def verify_email
    @verify_email_link = email_verification_url(token: @user.verification_token)
  end

  def update_password
    @edit_password_link = edit_user_password_url(@user, token: @user.verification_token)
  end

  private

  def mail_user
    mail(to: @user.email)
  end
end
