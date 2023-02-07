# frozen_string_literal: true

require "test_helper"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    login_as :legacy_user

    get new_email_verification_path
    assert_response :success
  end

  test "should create email_verification" do
    login_as :legacy_user
    assert_difference "ActionMailer::Base.deliveries.size" do
      post email_verification_path
    end
    assert_redirected_to dashboard_path
  end

  test "should get show" do
    login_as :legacy_user

    get email_verification_path
    assert_response :success
  end
end
