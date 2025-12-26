# frozen_string_literal: true

require "bcrypt"

module MinimalistAuthentication
  module User
    extend ActiveSupport::Concern

    included do
      has_secure_password reset_token: { expires_in: password_reset_duration }

      # Tracks if password was explicitly set. Used to conditionally require password presence.
      attribute :password_updated, :boolean, default: false

      define_method(:password=) do |value|
        self.password_updated = true
        super(value)
      end

      generates_token_for :account_setup, expires_in: account_setup_duration do
        password_salt&.last(10)
      end

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
      delegate :account_setup_duration, :password_reset_duration, to: "MinimalistAuthentication.configuration"

      # Finds an enabled user by id.
      def find_enabled(id)
        find_enabled_by(id:) if id.present?
      end

      # Finds a user matching the specified conditions and returns the user if they are enabled.
      # Returns nil if a user is not found or not enabled.
      def find_enabled_by(**)
        find_by(**)&.enabled
      end

      def inactive
        MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
          Calling #inactive is deprecated. Use #active(false) instead.
        MSG
        active(false)
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

    # Remove the has_secure_password password blank error when password is not required.
    def errors
      super.tap { |errors| errors.delete(:password, :blank) unless password_required? }
    end

    # Returns true if password matches the hashed_password, otherwise returns false.
    def authenticated?(password)
      MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
        Calling #authenticated? is deprecated. Use #authenticate instead.
      MSG
      authenticate(password)
    end

    # Deprecated method to check if the user is a guest. Returns false because the guest user has been removed.
    def guest?
      MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
        Calling #guest? is deprecated. Use #MinimalistAuthentication::Controller#logged_in? to
        check for the presence of a current_user instead.
      MSG

      false
    end

    # Returns true if the user is not active.
    def inactive?
      !active?
    end

    # Sets #last_logged_in_at to the current time without updating the updated_at timestamp.
    def logged_in
      update_column(:last_logged_in_at, Time.current)
    end

    # Overridden by EmailVerification to verify email upon update.
    def verified_update(*)
      update(*)
    end

    private

    # Password presence is required for active users who are updating their password.
    def password_required?
      active? && password_updated?
    end

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
