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
    # The duration for which the account_activation token is valid.
    # Defaults to 1.day
    attr_accessor :account_activation_duration

    # The duration for which the email_verification token is valid.
    # Defaults to 1.hour
    attr_accessor :email_verification_duration

    # Where to route users after a successful login.
    # Defaults to :root_path
    attr_accessor :login_redirect_path

    # Where to route users after logging out.
    # Defaults to :new_session_path
    attr_accessor :logout_redirect_path

    # The duration for which the password_reset token is valid.
    # Defaults to 1.hour
    attr_accessor :password_reset_duration

    # Check for users email at login and request if blank. Only useful if using
    # username to login and users might not have an email set.
    # Defaults to true
    attr_accessor :request_email

    # The session_key used to store the current_user id.
    # Defaults to :user_id
    attr_accessor :session_key

    # The application user class name
    # Defaults to "::User"
    attr_accessor :user_model_name

    # Toggle all email validations.
    # Defaults to true.
    attr_accessor :validate_email

    # Toggle email presence validation.
    # Defaults to true.
    # Note: validate_email_presence is only checked if validate_email is true.
    attr_accessor :validate_email_presence

    # Verify users email address at login.
    # Defaults to true.
    attr_accessor :verify_email

    def initialize
      @account_activation_duration  = 1.day
      @email_verification_duration  = 1.hour
      @login_redirect_path          = :root_path
      @logout_redirect_path         = :new_session_path
      @password_reset_duration      = 1.hour
      @request_email                = true
      @session_key                  = :user_id
      @user_model_name              = "::User"
      @validate_email               = true
      @validate_email_presence      = true
      @verify_email                 = true
    end

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
