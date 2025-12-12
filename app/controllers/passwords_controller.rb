# frozen_string_literal: true

class PasswordsController < ApplicationController
  ACTION_TOKEN_PURPOSES = ActiveSupport::HashWithIndifferentAccess.new(
    new:    :account_setup,
    create: :account_setup,
    edit:   :password_reset,
    update: :password_reset
  ).freeze

  attr_reader :user

  skip_before_action :authorization_required
  before_action :authenticate_with_token

  layout "sessions"

  # Set password form
  def new
    # new.html.erb
  end

  # Sets user password
  def create
    update_password(:new)
  end

  # Update password form
  def edit
    # edit.html.erb
  end

  # Resets user password
  def update
    update_password(:new)
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

  def update_password(template)
    if user.verified_update(password_params)
      redirect_to new_session_path, notice: t(".notice")
    else
      render template, status: :unprocessable_content
    end
  end
end
