# frozen_string_literal: true

require "test_helper"

module MinimalistAuthentication
  class ApplicationHelperTest < ActionView::TestCase
    test "ma_confirm_password_field" do
      assert_includes ma_confirm_password_field(form), "Password confirmation"
    end

    test "ma_email_field" do
      @virtual_path = "password_resets.new"

      assert_includes ma_email_field(form), t(".email.placeholder")
    end

    test "ma_forgot_password_link" do
      @virtual_path = "sessions.new"

      assert_includes ma_forgot_password_link, t(".forgot_password")
    end

    test "ma_new_password_field" do
      assert_includes ma_new_password_field(form), "Password"
    end

    test "ma_password_field" do
      assert_includes ma_password_field(form), "Password"
    end

    test "ma_username_field" do
      assert_includes ma_username_field(form), "Username"
    end

    private

    def form
      FormBuilder.new(:test, MinimalistAuthentication.user_model.new, self, {})
    end
  end
end
