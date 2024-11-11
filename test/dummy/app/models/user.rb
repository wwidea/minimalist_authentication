# frozen_string_literal: true

class User < ApplicationRecord
  include MinimalistAuthentication::User
  include MinimalistAuthentication::EmailVerification
end
