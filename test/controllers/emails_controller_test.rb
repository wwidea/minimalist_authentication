# frozen_string_literal: true

require "test_helper"

class EmailsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login_as :active_user
  end

  test "should get edit" do
    get edit_email_path

    assert_response :success
  end

  test "should update email" do
    patch email_path(user: { email: "testing@example.com" })

    assert_equal "testing@example.com", users(:active_user).reload.email
    assert_redirected_to new_email_verification_path
  end

  test "should redirect to dashboard if email not changed" do
    users(:active_user).update_columns(email: "active_user@example.com", email_verified_at: Time.zone.now)
    patch email_path(user: { email: "active_user@example.com" })

    assert_redirected_to dashboard_path
  end

  test "should fail to update email" do
    patch email_path(user: { email: "testing-invalid" })

    assert_response :unprocessable_entity
  end
end
