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

    # The application user class
    # Defaults to ::User
    attr_writer   :user_model

    def initialize
      self.session_key = :user_id
    end

    def user_model
      @user_model ||= ::User
    end
  end
end
