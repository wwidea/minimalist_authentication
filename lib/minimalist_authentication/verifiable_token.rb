module MinimalistAuthentication
  module VerifiableToken
    extend ActiveSupport::Concern

    TOKEN_EXPIRATION_HOURS = 6

    # generate secure verification_token and record generation time
    def regenerate_verification_token
      update_token
    end

    def secure_update(token, attributes)
      if matches_verification_token?(token)
        update(attributes) && clear_token
      else
        errors.add(:base, 'Verfication token check failed')
        return false
      end
    end

    def matches_verification_token?(token)
      verification_token_valid? && secure_match?(token, verification_token)
    end

    def verification_token_valid?
      return false if verification_token.blank? || verification_token_generated_at.blank?
      verification_token_generated_at > TOKEN_EXPIRATION_HOURS.hours.ago
    end

    private

    def clear_token
      update_token(token: nil, time: nil)
    end

    def update_token(token: self.class.generate_unique_secure_token, time: Time.now.utc)
      update!(
        verification_token:               token,
        verification_token_generated_at:  time
      )
    end

    # Compare the tokens in a time-constant manner, to mitigate timing attacks.
    def secure_match?(token1, token2)
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(token1),
        ::Digest::SHA256.hexdigest(token2)
      )
    end
  end
end
