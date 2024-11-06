# frozen_string_literal: true

module MinimalistAuthentication
  class Engine < ::Rails::Engine
    config.to_prepare do
      MinimalistAuthentication.configuration.clear_user_model
    end
  end
end
