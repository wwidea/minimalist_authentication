class PasswordsController < ApplicationController
  skip_before_action :authorization_required

  layout 'sessions'

  # From for user to update password
  def edit
    redirect_to(new_session_path) unless user.matches_verification_token?(token)
    # render passwords/edit.html.erb
  end

  # Update user's password
  def update
    if user.secure_update(token, password_params)
      redirect_to new_session_path, notice: 'Password successfully updated'
    else
      render :edit
    end
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def token
    @token ||= params[:token]
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
