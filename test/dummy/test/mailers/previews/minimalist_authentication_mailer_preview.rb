# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/minimalist_authentication_mailer
class MinimalistAuthenticationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/minimalist_authentication_mailer/verify_email
  def verify_email
    user = User.find_by(email: "legacy@example.com")
    user.regenerate_verification_token
    MinimalistAuthenticationMailer.verify_email(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/minimalist_authentication_mailer/update_password
  def update_password
    user = User.find_by(email: "active@example.com")
    user.regenerate_verification_token
    MinimalistAuthenticationMailer.update_password(user)
  end
end
