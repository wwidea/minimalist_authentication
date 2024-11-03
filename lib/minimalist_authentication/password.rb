# frozen_string_literal: true

module MinimalistAuthentication
  class Password
    class << self
      # Create a bcrypt password hash with a calibrated cost factor.
      def create(secret)
        new ::BCrypt::Engine.hash_secret(secret, BCrypt::Engine.generate_salt(cost))
      end

      # Cache the calibrated bcrypt cost factor.
      def cost
        @cost ||= calibrate_cost
      end

      private

      # Calibrates cost so that new user passwords can automatically take
      # advantage of faster server hardware in the future.
      # Sets cost to BCrypt::Engine::MIN_COST in the test environment
      def calibrate_cost
        ::Rails.env.test? ? ::BCrypt::Engine::MIN_COST : ::BCrypt::Engine.calibrate(750)
      end
    end

    attr_accessor :bcrypt_password

    # Returns a password object wrapping a valid BCrypt password or a NullPassword
    def initialize(password_digest)
      self.bcrypt_password = ::BCrypt::Password.new(password_digest)
    rescue ::BCrypt::Errors::InvalidHash
      self.bcrypt_password = NullPassword.new
    end

    # Delegate methods to bcrypt_password
    delegate :==, :to_s, :cost, to: :bcrypt_password

    # Temporary access to checksum and salt for backwards compatibility
    delegate :checksum, :salt,  to: :bcrypt_password

    # Checks if the password_digest cost factor is less than the current cost.
    def stale?
      cost < self.class.cost
    end
  end
end
