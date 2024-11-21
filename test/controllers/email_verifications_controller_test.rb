# frozen_string_literal: true

require "test_helper"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login_as :legacy_user
  end

  test "should get show for successful email verification" do
    get email_verification_path(token: users(:legacy_user).generate_token_for(:email_verification))

    assert_response :success
    assert_select "h2", text: "Your email address has been verified"
  end

  test "should get show for failed email verification" do
    get email_verification_path

    assert_response :success
    assert_select "h2", text: "Email address verification failed"
  end

  test "should get new" do
    get new_email_verification_path

    assert_response :success
  end

  test "should create email_verification" do
    assert_emails 1 do
      post email_verification_path
    end
    assert_redirected_to dashboard_path
  end
end
