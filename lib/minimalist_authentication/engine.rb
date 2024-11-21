# frozen_string_literal: true

module MinimalistAuthentication
  class Engine < ::Rails::Engine
    isolate_namespace MinimalistAuthentication

    config.to_prepare do
      MinimalistAuthentication.configuration.clear_user_model
    end
  end
end
