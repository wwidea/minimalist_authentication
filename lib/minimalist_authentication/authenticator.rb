# frozen_string_literal: true

module MinimalistAuthentication
  class Authenticator
    LOGIN_FIELDS = %w[email username].freeze

    attr_reader :field, :value, :password

    # Attempts to find and authenticate a user based on the provided params. Expects a params
    # hash with email or username and password keys. Returns user upon successful authentication.
    # Otherwise returns nil.
    #
    # Params examples:
    # { email: 'user@example.com', password: 'abc123' }
    # { username: 'user', password: 'abc123' }
    def self.authenticate(params)
      hash = params.to_h.with_indifferent_access
      field, value = hash.find { |key, _| LOGIN_FIELDS.include?(key) }
      new(field:, value:, password: hash["password"]).authenticated_user
    end

    def self.authenticated_user(params)
      MinimalistAuthentication.deprecator.warn(<<-MSG.squish)
        Calling MinimalistAuthentication::Authenticator.authenticated_user is deprecated.
        Use MinimalistAuthentication::Authenticator.authenticate instead.
      MSG
      authenticate(params)
    end

    # Initializes a new Authenticator instance with the provided field, value, and password.
    def initialize(field:, value:, password:)
      @field    = field
      @value    = value
      @password = password
    end

    # Returns an authenticated and enabled user or nil.
    def authenticated_user
      authenticated&.enabled if valid?
    end

    private

    # Attempts to authenticate a user based on the provided field, value, and password.
    # Returns user upon successful authentication, otherwise returns nil.
    def authenticated
      MinimalistAuthentication.configuration.user_model.authenticate_by(field => value, password:)
    end

    # Returns true if all the authentication attributes are present.
    # Otherwise returns false.
    def valid?
      [field, value, password].all?(&:present?)
    end
  end
end
