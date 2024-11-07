# frozen_string_literal: true

class EmailVerificationsController < ApplicationController
  # Verifies the email of the current_user using the provided token
  def show
    current_user.verify_email(params[:token])
  end

  # Form for current_user to request an email verification email
  def new
    # new.html.erb
  end

  # Sends an email verification email to the current_user
  def create
    MinimalistAuthenticationMailer.with(user: current_user).verify_email.deliver_now
    redirect_to dashboard_path, notice: t(".notice", email: current_user.email)
  end
end
