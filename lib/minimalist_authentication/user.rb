require 'bcrypt'

module MinimalistAuthentication
  module User
    extend ActiveSupport::Concern

    GUEST_USER_EMAIL = 'guest'
    EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

    included do
      # Stores the plain text password.
      attr_accessor :password

      # Hashes and stores the password on save.
      before_save :hash_password

      # Email validations
      validates_presence_of     :email,                                       if: :validate_email_presence?
      validates_uniqueness_of   :email, allow_blank: true,                    if: :validate_email?
      validates_format_of       :email, allow_blank: true, with: EMAIL_REGEX, if: :validate_email?

      # Password validations
      validates_presence_of     :password,                  if: :validate_password?
      validates_confirmation_of :password,                  if: :validate_password?
      validates_length_of       :password, within: 8..40,   if: :validate_password?

      # Active scope
      scope :active, ->(active = true) { where active: active }
    end

    module ClassMethods
      # Authenticates a user form the params provided. Expects a params hash with
      # email or username and passwod keys.
      # Params examples:
      # { email: 'user@example.com', password: 'abc123' }
      # { username: 'user', password: 'abc123' }
      # Returns user upon successful authentcation.
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
        return user
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

    # Return true if password matches the hashed_password.
    # If successful checks for an outdated password_hash and updates if
    # necessary.
    def authenticated?(password)
      if password_object == password
        update_hash!(password) if password_object.stale?
        return true
      end

      return false
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

    # Requre password for active users that either do no have a password hash
    # stored OR are attempting to set a new password.
    def validate_password?
      active? && (password_hash.blank? || password.present?)
    end

    # Validate email for active users.
    # Applications can turn off email validation by setting the validate_email
    # configuration attribute to false.
    def validate_email?
      MinimalistAuthentication.configuration.validate_email && active?
    end

    # Validate email presence for active users.
    # Applications can turn offf email presence validation by setting
    # validate_email_presence configuration attribute to false.
    def validate_email_presence?
      MinimalistAuthentication.configuration.validate_email_presence && validate_email?
    end
  end
end
