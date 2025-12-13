# frozen_string_literal: true

module MinimalistAuthentication
  module TestHelper
    NEW_PASSWORD = "abcdef123456"
    PASSWORD = "test-password"
    PASSWORD_DIGEST = BCrypt::Password.create(PASSWORD, cost: BCrypt::Engine::MIN_COST)

    def current_user
      @current_user ||= load_user_from_session
    end

    def login_as(user_fixture_name, password = PASSWORD)
      post session_path, params: { user: { email: users(user_fixture_name).email, password: } }
    end

    private

    def load_user_from_session
      MinimalistAuthentication.user_model.find(session_user_id) if session_user_id
    end

    def session_user_id
      @request.session[MinimalistAuthentication.session_key]
    end
  end
end
