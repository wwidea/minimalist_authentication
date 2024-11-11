# frozen_string_literal: true

require "bcrypt"

module MinimalistAuthentication
  module User
    extend ActiveSupport::Concern

    GUEST_USER_EMAIL = "guest"

    included do
      has_secure_password

      generates_token_for :password_reset, expires_in: 1.hour do
        password_salt.last(10)
      end

      # Force validations for a blank password.
      attribute :password_required, :boolean, default: false

      # Email validations
      validates(
        :email,
        format:     { allow_blank: true, with: URI::MailTo::EMAIL_REGEXP },
        uniqueness: { allow_blank: true, case_sensitive: false },
        if:         :validate_email?
      )
      validates(:email, presence: true, if: :validate_email_presence?)

      # Password validations
      # Adds validations for minimum password length and exclusivity.
      # has_secure_password adds validations for presence, maximum length, confirmation,
      # and password_challenge.
      validates :password, length: { minimum: :password_minimum }, if: :validate_password?
      validate :password_exclusivity, if: :password?

      # Active scope
      scope :active, ->(state = true) { where(active: state) }
    end

    module ClassMethods
      # Finds a user by their id and returns the user if they are enabled.
      # Returns nil if the user is not found or not enabled.
      def find_enabled(id)
        find_by(id:)&.enabled if id.present?
      end

      def inactive
        MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
          Calling #inactive is deprecated. Use #active(false) instead.
        MSG
        active(false)
      end

      # Returns a frozen user with the email set to GUEST_USER_EMAIL.
      def guest
        new(email: GUEST_USER_EMAIL).freeze
      end
    end

    # Called after a user is authenticated to determine if the user object should be returned.
    def enabled
      self if enabled?
    end

    # Returns true if the user is enabled.
    # Override this method in your user model to implement custom logic that determines if a user is eligible to log in.
    def enabled?
      active?
    end

    # Remove the has_secure_password password blank error if password is not required.
    def errors
      super.tap { |errors| errors.delete(:password, :blank) unless validate_password? }
    end

    # Returns true if the user is not active.
    def inactive?
      MinimalistAuthentication.deprecator.warn("Calling #inactive? is deprecated.")
      !active?
    end

    # Returns true if password matches the hashed_password, otherwise returns false.
    def authenticated?(password)
      MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
        Calling #authenticated? is deprecated. Use #authenticate instead.
      MSG
      authenticate(password)
    end

    # Check if user is a guest based on their email attribute
    def guest?
      email == GUEST_USER_EMAIL
    end

    # Sets #last_logged_in_at to the current time without updating the updated_at timestamp.
    def logged_in
      update_column(:last_logged_in_at, Time.current)
    end

    # Minimum password length
    def password_minimum = 12

    # Checks for password presence
    def password?
      password.present?
    end

    private

    # Ensure password does not match username or email.
    def password_exclusivity
      %w[username email].each do |field|
        errors.add(:password, "can not match #{field}") if password.casecmp?(try(field))
      end
    end

    # Return true if the user matches the owner of the provided token.
    def token_owner?(purpose, token)
      self.class.find_by_token_for(purpose, token) == self
    end

    # Require password for active users that either do no have a password hash
    # stored OR are attempting to set a new password. Set **password_required**
    # to true to force validations even when the password field is blank.
    def validate_password?
      active? && (password_digest.blank? || password? || password_required?)
    end

    # Validate email for all users.
    # Applications can turn off email validation by setting the validate_email
    # configuration attribute to false.
    def validate_email?
      MinimalistAuthentication.configuration.validate_email
    end

    # Validate email presence for active users.
    # Applications can turn off email presence validation by setting
    # validate_email_presence configuration attribute to false.
    def validate_email_presence?
      MinimalistAuthentication.configuration.validate_email_presence && validate_email? && active?
    end
  end
end
