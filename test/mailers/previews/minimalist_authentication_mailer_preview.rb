# Preview all emails at http://localhost:3000/rails/mailers/minimalist_authentication_mailer
class MinimalistAuthenticationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/minimalist_authentication_mailer/verify_email
  def verify_email
    MinimalistAuthenticationMailer.verify_email
  end

  # Preview this email at http://localhost:3000/rails/mailers/minimalist_authentication_mailer/update_password
  def update_password
    MinimalistAuthenticationMailer.update_password
  end

end
