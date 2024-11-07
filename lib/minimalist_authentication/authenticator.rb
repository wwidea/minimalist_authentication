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
    def self.authenticated_user(params)
      hash = params.to_h.with_indifferent_access
      field, value = hash.find { |key, _| LOGIN_FIELDS.include?(key) }
      new(field:, value:, password: hash["password"]).authenticated_user
    end

    def initialize(field:, value:, password:)
      @field    = field
      @value    = value
      @password = password
    end

    # Returns user upon successful authentication, otherwise returns nil.
    def authenticated_user
      authenticate_by(field => value, password:) if valid?
    end

    private

    def authenticate_by(*args)
      MinimalistAuthentication.configuration.user_model.active.authenticate_by(*args)
    end

    # Returns true if all the authentication attributes are present.
    def valid?
      [field, value, password].all?(&:present?)
    end
  end
end
