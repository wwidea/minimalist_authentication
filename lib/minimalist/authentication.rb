require 'bcrypt'

module Minimalist
  module Authentication
    extend ActiveSupport::Concern

    GUEST_USER_EMAIL = 'guest'
    EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

    # Recalibrates cost when class is loaded so that new user passwords
    # can automatically take advantage of faster server hardware in the
    # future for better encryption.
    # sets cost to BCrypt::Engine::MIN_COST in the test environment
    CALIBRATED_BCRYPT_COST = (::Rails.env.test? ? ::BCrypt::Engine::MIN_COST : ::BCrypt::Engine.calibrate(750))

    included do
      attr_accessor :password
      before_save :encrypt_password

      # email validations
      validates_presence_of     :email,                                       if: :validate_email_presence?
      validates_uniqueness_of   :email, allow_blank: true,                    if: :validate_email?
      validates_format_of       :email, allow_blank: true, with: EMAIL_REGEX, if: :validate_email?

      # password validations
      validates_presence_of     :password,                  if: :password_required?
      validates_confirmation_of :password,                  if: :password_required?
      validates_length_of       :password, within: 6..40,   if: :password_required?

      scope :active, ->(active = true) { where active: active }
    end

    module ClassMethods
      def authenticate(params)
        field, value = params.to_h.select { |key, value| %w(email username).include?(key.to_s) && value.present? }.first
        return if field.blank? || value.blank? || params[:password].blank?
        user = active.where(field => value).first
        return unless user && user.authenticated?(params[:password])
        return user
      end

      def password_hash(password)
        ::BCrypt::Password.create(password, cost: calibrated_bcrypt_cost)
      end

      def calibrated_bcrypt_cost
        CALIBRATED_BCRYPT_COST
      end

      def guest
        new(email: GUEST_USER_EMAIL)
      end
    end

    def active?
      active
    end

    def authenticated?(password)
      if bcrypt_password == password
        update_encryption(password) if bcrypt_password.cost < self.class.calibrated_bcrypt_cost
        return true
      end

      return false
    end

    def logged_in
      # use update_column to avoid updated_on trigger
      update_column(:last_logged_in_at, Time.current)
    end

    def is_guest?
      email == GUEST_USER_EMAIL
    end

    private

    def password_required?
      active? && (crypted_password.blank? || !password.blank?)
    end

    def update_encryption(password)
      self.password = password
      encrypt_password
      save
    end

    def encrypt_password
      return if password.blank?
      password_hash         = self.class.password_hash(password)
      self.salt             = password_hash.salt
      self.crypted_password = password_hash.checksum
    end

    def bcrypt_password
      valid_hash? ? ::BCrypt::Password.new(password_hash) : null_password
    end

    def valid_hash?
      ::BCrypt::Password.valid_hash?(password_hash)
    end

    def password_hash
      "#{salt}#{crypted_password}"
    end

    def null_password
      MinimalistAuthentication::NullPassword.new
    end

    # email validation
    def validate_email?
      # allows applications to turn off all email validation
      active?
    end

    def validate_email_presence?
      # allows applications to turn off email presence validation
      validate_email?
    end
  end
end
