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
    MinimalistAuthenticationMailer.verify_email(current_user).deliver_now

    redirect_to dashboard_path, notice: t(".notice", email: current_user.email)
  end
end
