# frozen_string_literal: true

module MinimalistAuthentication
  module EmailVerification
    extend ActiveSupport::Concern

    included do
      generates_token_for :email_verification, expires_in: 1.hour do
        email
      end

      before_save :clear_email_verification, if: ->(user) { user.email_changed? }

      scope :email_verified, -> { where("LENGTH(email) > 2").where.not(email_verified_at: nil) }
    end

    def needs_email_set?
      request_email_enabled? && email.blank?
    end

    def needs_email_verification?
      email_verification_enabled? && email.present? && email_verified_at.blank?
    end

    def email_verified?
      email.present? && email_verified_at.present?
    end

    def verify_email(token)
      secure_update(token, email_verified_at: Time.zone.now)
    end

    private

    def request_email_enabled?
      MinimalistAuthentication.configuration.request_email
    end

    def email_verification_enabled?
      MinimalistAuthentication.configuration.verify_email
    end

    def clear_email_verification
      self.email_verified_at = nil
    end
  end
end
