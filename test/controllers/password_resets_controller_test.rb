# frozen_string_literal: true

require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_password_reset_path

    assert_response :success
  end

  test "should create password reset email for known user" do
    assert_difference "ActionMailer::Base.deliveries.size" do
      post password_reset_path(user: { email: users(:active_user).email } )

      assert users(:active_user).reload.verification_token.present?
    end
    assert_redirected_to new_session_path
  end

  test "should fail to create password reset email for unknown user" do
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      post password_reset_path(user: { email: "not_a_user@example.com" } )
    end
    assert_redirected_to new_session_path
  end

  test "should raise error when email paramater is not provided" do
    assert_raise ActionController::ParameterMissing do
      post password_reset_path(user: { foo: "bar" } )
    end
  end
end
