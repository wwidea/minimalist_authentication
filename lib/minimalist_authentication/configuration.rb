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
    # The session_key used to store the current_user id.
    # Defaults to :user_id
    attr_accessor :session_key

    # The application user class name
    # Defaults to '::User'
    attr_accessor :user_model_name

    # Toggle all email validations.
    # Defaults to true.
    attr_accessor :validate_email

    # Toggle email presence validation.
    # Defaults to true.
    # Note: validate_email_presence is only checked if validate_email is true.
    attr_accessor :validate_email_presence

    # Check for users email at login and request if blank. Only useful if using
    # username to login and users might not have an email set.
    attr_accessor :request_email

    # Vefify users email address at login.
    # Defautls to true.
    attr_accessor :verify_email

    def initialize
      self.user_model_name          = '::User'
      self.session_key              = :user_id
      self.validate_email           = true
      self.validate_email_presence  = true
      self.request_email            = true
      self.verify_email             = true
    end

    # Returns the user_model class
    # Calling constantize on a string makes this work correctly with
    # the spring application preloader gem.
    def user_model
      @user_model ||= user_model_name.constantize
    end
  end
end
