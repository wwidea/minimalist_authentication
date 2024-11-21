# frozen_string_literal: true

require "test_helper"

module MinimalistAuthentication
  class FormFieldsHelperTest < ActionView::TestCase
    test "should return password_reset_email_field" do
      @virtual_path = "password_resets.new"

      form_with scope: :user, url: "#" do |form|
        assert_includes password_reset_email_field(form), t(".placeholder")
      end
    end
  end
end
