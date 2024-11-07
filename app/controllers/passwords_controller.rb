# frozen_string_literal: true

class PasswordsController < ApplicationController
  skip_before_action :authorization_required

  before_action :validate_token, only: %i[edit update]

  layout "sessions"

  # From for user to update password
  def edit
    # edit.html.erb
  end

  # Update user's password
  def update
    if user.update(password_params.merge(password_required: true))
      redirect_to new_session_path, notice: t(".notice")
    else
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def token
    @token ||= params[:token]
  end

  def user
    @user ||= MinimalistAuthentication.user_model.active.find_by_token_for(:password_reset, token)
  end

  def validate_token
    redirect_to(new_session_path, alert: t(".invalid_token")) unless user
  end
end
