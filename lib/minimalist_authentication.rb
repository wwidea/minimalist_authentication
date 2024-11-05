# frozen_string_literal: true

require "minimalist_authentication/engine"
require "minimalist_authentication/authenticator"
require "minimalist_authentication/configuration"
require "minimalist_authentication/user"
require "minimalist_authentication/verifiable_token"
require "minimalist_authentication/email_verification"
require "minimalist_authentication/controller"
require "minimalist_authentication/sessions"
require "minimalist_authentication/test_helper"

module MinimalistAuthentication
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("3.0", name)
  end
end
