# frozen_string_literal: true

require "test_helper"

module MinimalistAuthentication
  class ApplicationHelperTest < ActionView::TestCase
    test "should return ma_confirm_password_field" do
      @virtual_path = "passwords.edit"

      test_form do |form|
        assert_includes ma_confirm_password_field(form), t(".password_confirmation.placeholder")
      end
    end

    test "should return ma_email_field" do
      @virtual_path = "password_resets.new"

      test_form do |form|
        assert_includes ma_email_field(form), t(".email.placeholder")
      end
    end

    test "should return ma_forgot_password_link" do
      @virtual_path = "sessions.new"

      assert_includes ma_forgot_password_link, t(".forgot_password")
    end

    test "should return ma_new_password_field" do
      @virtual_path = "passwords.edit"

      test_form do |form|
        assert_includes ma_new_password_field(form), t(".password.placeholder")
      end
    end

    test "should return ma_password_field" do
      @virtual_path = "sessions.new"

      test_form do |form|
        assert_includes ma_password_field(form), "Password"
      end
    end

    test "should return ma_username_field" do
      @virtual_path = "sessions.new"

      test_form do |form|
        assert_includes ma_username_field(form), "Username"
      end
    end

    private

    def test_form(&)
      form_with(scope: :test, url: "#", &)
    end
  end
end
