# frozen_string_literal: true

require "bcrypt"

module MinimalistAuthentication
  module User
    extend ActiveSupport::Concern

    GUEST_USER_EMAIL = "guest"

    included do
      has_secure_password validations: false

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
      validates(
        :password,
        confirmation: true,
        length:       { minimum: :password_minimum, maximum: :password_maximum },
        presence:     true,
        if:           :validate_password?
      )
      validate :password_exclusivity, if: :password?

      # Active scope
      scope :active,    ->(state = true)  { where(active: state) }
      scope :inactive,  ->                { active(false) }
    end

    module ClassMethods
      # Returns a frozen user with the email set to GUEST_USER_EMAIL.
      def guest
        new(email: GUEST_USER_EMAIL).freeze
      end
    end

    # Returns true if the user is not active.
    def inactive?
      !active?
    end

    # Returns true if password matches the hashed_password, otherwise returns false.
    def authenticated?(password)
      authenticate(password)
    rescue ::BCrypt::Errors::InvalidHash
      false
    end

    # Check if user is a guest based on their email attribute
    def guest?
      email == GUEST_USER_EMAIL
    end

    def logged_in
      # Use update_column to avoid updated_on trigger
      update_column(:last_logged_in_at, Time.current)
    end

    # Minimum password length
    def password_minimum = 12

    # Maximum password length
    def password_maximum = 40

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
