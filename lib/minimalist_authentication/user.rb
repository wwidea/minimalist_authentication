require 'bcrypt'

module MinimalistAuthentication
  module User
    extend ActiveSupport::Concern

    GUEST_USER_EMAIL = 'guest'
    EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

    included do
      attr_accessor :password
      before_save :hash_password

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

      def guest
        new(email: GUEST_USER_EMAIL)
      end
    end

    def active?
      active
    end

    def authenticated?(password)
      if password_object == password
        update_hash(password) if password_object.stale?
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
      active? && (password_hash.blank? || !password.blank?)
    end

    def update_hash(password)
      self.password = password
      hash_password
      save
    end

    def hash_password
      return if password.blank?
      self.password_hash = Password.create(password)
    end

    def password_object
      Password.new(password_hash)
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
