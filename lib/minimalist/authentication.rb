require 'digest/sha1'
require 'bcrypt'

module Minimalist
  module Authentication
    GUEST_USER_EMAIL = 'guest'
    PREFERRED_DIGEST_VERSION = 3

    # Recalibrates cost when class is loaded so that new user passwords
    # can automatically take advantage of faster server hardware in the
    # future for better encryption.
    CALIBRATED_BCRYPT_COST = BCrypt::Engine.calibrate(750)

    def self.included( base )
      base.extend(ClassMethods)
      base.class_eval do
        include InstanceMethods
        
        attr_accessor :password
        before_save :encrypt_password
        
        validates_presence_of     :email, :if => :validate_email_presence?
        validates_uniqueness_of   :email, :if => :validate_email_uniqueness?
        validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :validate_email_format?
        validates_presence_of     :password,                   :if => :password_required?
        validates_confirmation_of :password,                   :if => :password_required?
        validates_length_of       :password, :within => 6..40, :if => :password_required?
        
        scope :active, :conditions => {:active => true}
      end
    end
    
    module ClassMethods
      def authenticate(email, password)
        return if email.blank? || password.blank?
        user = active.first(:conditions => {:email => email})
        return unless user && user.authenticated?(password)
        return user
      end
      
      def secure_digest(string, salt, version = 1)
        case version
          when 0 then Digest::MD5.hexdigest(string.to_s)
          when 1 then Digest::SHA1.hexdigest("#{string}--#{salt}")
          when 2 then Digest::SHA2.hexdigest("#{string}#{salt}", 512)
          when 3 then BCrypt::Password.new(BCrypt::Engine.hash_secret(string, salt)).checksum
        end
      end

      def make_token
        BCrypt::Engine.generate_salt(CALIBRATED_BCRYPT_COST)
      end
      
      def guest
        new.tap do |user|
          user.email = GUEST_USER_EMAIL
        end
      end
    end
    
    module InstanceMethods
      
      def active?
        active
      end
      
      def authenticated?(password)
        if crypted_password == encrypt(password)
          if self.respond_to?(:using_digest_version) and (using_digest_version != PREFERRED_DIGEST_VERSION or salt_cost < CALIBRATED_BCRYPT_COST)
            new_salt = self.class.make_token
            self.update_attribute(:crypted_password,self.class.secure_digest(password, new_salt, PREFERRED_DIGEST_VERSION))
            self.update_attribute(:salt, new_salt)
            self.update_attribute(:using_digest_version, PREFERRED_DIGEST_VERSION)
          end
          return true
        else
          return false
        end
      end
      
      def logged_in
        self.class.update_all("last_logged_in_at='#{Time.now.to_s(:db)}'", "id=#{self.id}") # use update_all to avoid updated_on trigger
      end
      
      def is_guest?
        email == GUEST_USER_EMAIL
      end
      
      #######
      private
      #######
      
      def password_required?
        active? && (crypted_password.blank? || !password.blank?)
      end
      
      def encrypt(password)
        self.class.secure_digest(password, salt, digest_version)
      end
      
      def encrypt_password
        return if password.blank?
        self.salt = self.class.make_token if new_record?
        self.crypted_password = self.class.secure_digest(password, salt, (self.respond_to?(:using_digest_version) ? PREFERRED_DIGEST_VERSION : 1))
        self.using_digest_version = PREFERRED_DIGEST_VERSION if self.respond_to?(:using_digest_version)
      end
      
      def digest_version
        self.respond_to?(:using_digest_version) ? (using_digest_version || 1) : 1
      end
      
      def salt_cost
        BCrypt::Engine.valid_salt?(salt) ? salt.match(/\$[^\$]+\$([0-9]+)\$/)[1].to_i : 0
      end

      # email validation
      def validate_email?
        # allows applications to turn off email validation
        true
      end
      
      def validate_email_presence?
        validate_email? && active?
      end
      
      def validate_email_format?
        validate_email? && active?
      end
      
      def validate_email_uniqueness?
        validate_email? && active?
      end
    end
  end
end
