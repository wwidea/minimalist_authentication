# frozen_string_literal: true

module MinimalistAuthentication
  # store the configuration object
  def self.configuration
    @configuration ||= Configuration.new
  end

  # yield the configuration object for modification
  def self.configure
    yield configuration
  end

  # reset the configuration object
  def self.reset_configuration!
    @configuration = nil
  end

  class Configuration
    include ActiveModel::Attributes

    # The duration for which the account_setup token is valid.
    attribute :account_setup_duration, default: 1.day

    # The duration for which the email_verification token is valid.
    attribute :email_verification_duration, default: 1.hour

    # Where to route users after a successful login.
    attribute :login_redirect_path, default: :root_path

    # Where to route users after logging out.
    attribute :logout_redirect_path, default: :new_session_path

    # The duration for which the password_reset token is valid.
    attribute :password_reset_duration, default: 1.hour

    # Check for users email at login and request if blank. Only useful if using
    # username to login and users might not have an email set.
    attribute :request_email, :boolean, default: true

    # The session_key used to store the current_user id.
    attribute :session_key, default: :user_id

    # The application user class name
    attribute :user_model_name, :string, default: "::User"

    # Toggle all email validations.
    attribute :validate_email, :boolean, default: true

    # Toggle email presence validation.
    # Note: validate_email_presence is only checked if validate_email is true.
    attribute :validate_email_presence, :boolean, default: true

    # Verify users email address at login.
    attribute :verify_email, :boolean, default: true

    # Clear the user_model class
    def clear_user_model
      @user_model = nil
    end

    # Display deprecation warning for email_prefix
    def email_prefix=(_)
      MinimalistAuthentication.deprecator.warn("The #email_prefix configuration setting is no longer supported.")
    end

    # Returns the user_model class
    def user_model
      @user_model ||= user_model_name.constantize
    end
  end
end
