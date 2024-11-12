# frozen_string_literal: true

module MinimalistAuthentication
  module VerifiableToken
    extend ActiveSupport::Concern

    included do
      MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
        MinimalistAuthentication::VerifiableToken is no longer required.
        You can safely remove the include from your user model.
      MSG
    end

    def regenerate_verification_token
      MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
        Calling #regenerate_verification_token is deprecated and no longer generates tokens.
        Call #generate_token_for with an argument of :password_reset or
        :email_verification instead.
      MSG
    end

    def verification_token
      MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
        Calling #verification_token is deprecated and no longer returns a valid token.
        Call #generate_token_for with an argument of :password_reset or
        :email_verification instead.
      MSG
    end
  end
end
