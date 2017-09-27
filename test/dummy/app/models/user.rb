class User < ApplicationRecord
  include MinimalistAuthentication::User
  include MinimalistAuthentication::VerifiableToken
  include MinimalistAuthentication::EmailVerification
end
