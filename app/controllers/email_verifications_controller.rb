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

    redirect_to dashboard_path, notice: "Verification email sent to #{current_user.email}, follow the instructions to complete verification. Thank you!"
  end
end
