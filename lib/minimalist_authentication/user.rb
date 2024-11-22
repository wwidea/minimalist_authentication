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
      # has_secure_password includes validations for presence, maximum length, confirmation, and password_challenge.
      validates(
        :password,
        password_exclusivity: true,
        length:               { minimum: :password_minimum },
        allow_blank:          true
      )

      # Active scope
      scope :active, ->(state = true) { where(active: state) }

      delegate :password_minimum, to: :class
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

      # Minimum password length
      def password_minimum = 12
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

    # Remove the has_secure_password password blank error if user is inactive.
    def errors
      super.tap { |errors| errors.delete(:password, :blank) if inactive? }
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

    # Returns true if the user is not active.
    def inactive?
      !active?
    end

    # Sets #last_logged_in_at to the current time without updating the updated_at timestamp.
    def logged_in
      update_column(:last_logged_in_at, Time.current)
    end

    private

    # Return true if the user matches the owner of the provided token.
    def token_owner?(purpose, token)
      self.class.find_by_token_for(purpose, token) == self
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
