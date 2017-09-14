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

    def initialize
      self.user_model_name  = '::User'
      self.session_key      = :user_id
    end

    # Returns the user_model class
    # Calling constantize on a string makes this work correctly with
    # the spring application preloader gem.
    def user_model
      @user_model ||= user_model_name.constantize
    end
  end
end
