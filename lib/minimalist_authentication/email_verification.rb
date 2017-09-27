module MinimalistAuthentication
  module EmailVerification
    extend ActiveSupport::Concern

    included do
      before_save :clear_email_verification, if: ->(user) { user.email_changed? }

      scope :email_verified, -> { where('LENGTH(email) > 2').where.not(email_verified_at: nil) }
    end

    def needs_email_verification?
      email.present? && email_verified_at.blank?
    end

    def email_verified?
      email.present? && email_verified_at.present?
    end

    def verify_email(token)
      secure_update(token, email_verified_at: Time.zone.now)
    end

    private

    def clear_email_verification
      self.email_verified_at = nil
    end
  end
end
