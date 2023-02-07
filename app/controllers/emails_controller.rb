# frozen_string_literal: true

class EmailsController < ApplicationController
  def edit; end

  def update
    if current_user.update(user_params)
      redirect_to update_redirect_path, notice: "Email successfully updated"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end

  def update_redirect_path
    current_user.needs_email_verification? ? new_email_verification_path : dashboard_path
  end
end
