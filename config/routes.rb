# frozen_string_literal: true

Rails.application.routes.draw do
  resource :email_verification, only: %i[show new create]
  resource :email,              only: %i[edit update]
  resource :password_reset,     only: %i[new create]
  resource :password,           only: %i[new create edit update]
end
