# frozen_string_literal: true

require "minimalist_authentication/engine"
require "minimalist_authentication/authenticator"
require "minimalist_authentication/configuration"
require "minimalist_authentication/user"
require "minimalist_authentication/email_verification"
require "minimalist_authentication/controller"
require "minimalist_authentication/sessions"
require "minimalist_authentication/test_helper"

module MinimalistAuthentication
  class << self
    delegate :user_model, to: :configuration

    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("4.0", name)
    end
  end
end
