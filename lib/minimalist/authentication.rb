require 'digest/sha1'

module Minimalist
  module Authentication
    GUEST_USER_EMAIL = 'guest'
    
    def self.included( base )
      base.extend(ClassMethods)
      base.class_eval do
        include InstanceMethods
        
        attr_accessor :password
        attr_protected :crypted_password, :salt
        before_save :encrypt_password
        
        validates_presence_of     :email, :if => :active?
        validates_uniqueness_of   :email, :if => :active?
        validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :active?
        validates_presence_of     :password,                   :if => :password_required?
        validates_presence_of     :password_confirmation,      :if => :password_required?
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
      
      def secure_digest(*args)
        Digest::SHA1.hexdigest(args.flatten.join('--'))
      end

      def make_token
        secure_digest(Time.now, (1..10).map{ rand.to_s })
      end
      
      def guest
        User.new(:email => GUEST_USER_EMAIL)
      end
    end
    
    module InstanceMethods
      
      def active?
        active
      end
      
      def authenticated?(password)
        crypted_password == encrypt(password)
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
        self.class.secure_digest(password, salt)
      end
      
      def encrypt_password
        return if password.blank?
        self.salt = self.class.make_token if new_record?
        self.crypted_password = encrypt(password)
      end
    end
  end
end