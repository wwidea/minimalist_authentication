# frozen_string_literal: true

module MinimalistAuthentication
  module EmailVerification
    extend ActiveSupport::Concern

    included do
      generates_token_for :email_verification, expires_in: MinimalistAuthentication.configuration.email_verification_duration do
        email
      end

      before_save :clear_email_verification, if: :email_changed?

      scope :with_verified_email, -> { where.not(email_verified_at: nil) }
    end

    module ClassMethods
      def email_verified
        MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
          Calling #email_verified is deprecated.
          Call #with_verified_email instead.
        MSG
        with_verified_email
      end

      def find_by_verified_email(email:)
        active.with_verified_email.find_by(email:)
      end
    end

    def email_verified?
      email.present? && email_verified_at.present?
    end

    def needs_email_set?
      request_email_enabled? && email.blank?
    end

    def needs_email_verification?
      email_verification_enabled? && email.present? && email_verified_at.blank?
    end

    def verify_email
      touch(:email_verified_at)
    end

    def verify_email_with(token)
      verify_email if token_owner?(:email_verification, token)
    end

    private

    def clear_email_verification
      self.email_verified_at = nil
    end

    def email_verification_enabled?
      MinimalistAuthentication.configuration.verify_email
    end

    def request_email_enabled?
      MinimalistAuthentication.configuration.request_email
    end
  end
end
