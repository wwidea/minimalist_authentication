module MinimalistAuthentication
  module TestHelper
    def login_as(user_fixture_name, password = 'password')
      post session_path, params: { user: { email: users(user_fixture_name).email, password: password } }
    end


    def current_user
      @current_user ||= load_user_from_session
    end

    private

    def load_user_from_session
      MinimalistAuthentication.configuration.user_model.find(session_user_id) if session_user_id
    end

    def session_user_id
      @request.session[MinimalistAuthentication.configuration.session_key]
    end
  end
end
