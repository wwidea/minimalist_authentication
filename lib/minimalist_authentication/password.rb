module MinimalistAuthentication
  class Password
    class << self
      # Create a bcrypt password hash with a calibrated cost factor.
      def create(password)
        ::BCrypt::Password.create(password, cost: cost)
      end

      def stale?(password_hash)
        password_hash.cost < cost
      end

      # Cache the calibrated bcrypt cost factor.
      def cost
        @bcrypt_cost ||= calibrate_cost
      end

      private

      def calibrate_cost
        # Calibrates cost so that new user passwords can automatically take
        # advantage of faster server hardware in the future.
        # Sets cost to BCrypt::Engine::MIN_COST in the test environment
        ::Rails.env.test? ? ::BCrypt::Engine::MIN_COST : ::BCrypt::Engine.calibrate(750)
      end
    end
  end
end
