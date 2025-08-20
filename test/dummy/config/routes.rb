# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resource :dashboard,          only: :show
  resource :limited_creations,  only: :create
  resource :session,            only: %i[new create destroy]

  root to: "dashboards#show"
end
