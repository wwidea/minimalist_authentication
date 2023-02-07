# frozen_string_literal: true

require "bcrypt"

module MinimalistAuthentication
  module User
    extend ActiveSupport::Concern

    GUEST_USER_EMAIL  = "guest"
    PASSWORD_MIN      = 8
    PASSWORD_MAX      = 40

    included do
      # Stores the plain text password.
      attr_accessor :password

      # Force validations for a blank password.
      attr_accessor :password_required

      # Hashes and stores the password on save.
      before_save :hash_password

      # Email validations
      validates(
        :email,
        format:     { allow_blank: true, with: URI::MailTo::EMAIL_REGEXP },
        uniqueness: { allow_blank: true, case_sensitive: false, scope: :active },
        if:         :validate_email?
      )
      validates(:email, presence: true, if: :validate_email_presence?)

      # Password validations
      validates(
        :password,
        confirmation: true,
        length:       { within: PASSWORD_MIN..PASSWORD_MAX },
        presence:     true,
        if:           :validate_password?
      )

      # Active scope
      scope :active,    ->(state = true)  { where(active: state) }
      scope :inactive,  ->                { active(false) }
    end

    module ClassMethods
      # Authenticates a user form the params provided. Expects a params hash with
      # email or username and password keys.
      # Params examples:
      # { email: 'user@example.com', password: 'abc123' }
      # { username: 'user', password: 'abc123' }
      # Returns user upon successful authentication.
      # Otherwise returns nil.
      def authenticate(params)
        # extract email or username and the associated value
        field, value = params.to_h.select { |key, value| %w(email username).include?(key.to_s) && value.present? }.first
        # return nil if field, value, or password is blank
        return if field.blank? || value.blank? || params[:password].blank?
        # attempt to find the user using field and value
        user = active.where(field => value).first
        # check if a user was found and if they can be authenticated
        return unless user && user.authenticated?(params[:password])
        # return the authenticated user
        user
      end

      # Returns a frozen user with the email set to GUEST_USER_EMAIL.
      def guest
        new(email: GUEST_USER_EMAIL).freeze
      end
    end

    # Returns true if the user is active.
    def active?
      active
    end

    # Returns true if the user is not active.
    def inactive?
      !active
    end

    # Return true if password matches the hashed_password.
    # If successful checks for an outdated password_hash and updates if
    # necessary.
    def authenticated?(password)
      if password_object == password
        update_hash!(password) if password_object.stale?
        return true
      end

      false
    end

    def logged_in
      # use update_column to avoid updated_on trigger
      update_column(:last_logged_in_at, Time.current)
    end

    # Check if user is a guest based on their email attribute
    def is_guest?
      email == GUEST_USER_EMAIL
    end

    private

    # Set self.password to password, hash, and save
    def update_hash!(password)
      self.password = password
      hash_password
      save
    end

    # Hash password and store in hash_password unless password is blank.
    def hash_password
      return if password.blank?
      self.password_hash = Password.create(password)
    end

    # Retuns a MinimalistAuthentication::Password object.
    def password_object
      Password.new(password_hash)
    end

    # Require password for active users that either do no have a password hash
    # stored OR are attempting to set a new password. Set **password_required**
    # to true to force validations even when the password field is blank.
    def validate_password?
      active? && (password_hash.blank? || password.present? || password_required)
    end

    # Validate email for active users.
    # Applications can turn off email validation by setting the validate_email
    # configuration attribute to false.
    def validate_email?
      MinimalistAuthentication.configuration.validate_email && active?
    end

    # Validate email presence for active users.
    # Applications can turn off email presence validation by setting
    # validate_email_presence configuration attribute to false.
    def validate_email_presence?
      MinimalistAuthentication.configuration.validate_email_presence && validate_email?
    end
  end
end
