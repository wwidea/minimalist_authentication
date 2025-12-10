# frozen_string_literal: true

class PasswordsController < ApplicationController
  ACTION_TOKEN_PURPOSES = ActiveSupport::HashWithIndifferentAccess.new(
    new:    :account_activation,
    create: :account_activation,
    edit:   :password_reset,
    update: :password_reset
  ).freeze

  attr_reader :user

  skip_before_action :authorization_required
  before_action :authenticate_with_token

  layout "sessions"

  # Form for user to set password
  def new
    # new.html.erb
  end

  def create
    if user.update(password_params)
      user.try(:verify_email)
      redirect_to new_session_path, notice: t(".notice")
    else
      render :new, status: :unprocessable_content
    end
  end

  # Form for user to update password
  def edit
    # edit.html.erb
  end

  # Update user's password
  def update
    if user.update(password_params)
      redirect_to new_session_path, notice: t(".notice")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def authenticate_with_token
    @token = params[:token]
    @user = MinimalistAuthentication.user_model.active.find_by_token_for(purpose, @token)
    redirect_to(new_session_path, alert: t(".invalid_token")) unless @user
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def purpose
    ACTION_TOKEN_PURPOSES[action_name]
  end
end
