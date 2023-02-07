# frozen_string_literal: true

Rails.application.routes.draw do
  resources :user, only: [] do
    resource :password,         only: %i(edit update)
  end

  resource :password_reset,     only: %i(new create)

  resource :email,              only: %i(edit update)
  resource :email_verification, only: %i(new create show)
end
