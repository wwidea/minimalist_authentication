# frozen_string_literal: true

class EmailVerificationsController < ApplicationController
  def show
    current_user.verify_email(params[:token])
  end

  def new
    # verify email for current_user
  end

  def create
    current_user.regenerate_verification_token
    MinimalistAuthenticationMailer.with(user: current_user).verify_email.deliver_now

    redirect_to dashboard_path, notice: t(".notice", email: current_user.email)
  end
end
