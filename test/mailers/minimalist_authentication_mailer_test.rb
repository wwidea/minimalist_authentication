# frozen_string_literal: true

require "test_helper"

class MinimalistAuthenticationMailerTest < ActionMailer::TestCase
  test "verify_email" do
    assert_email(user: users(:legacy_user), template: :verify_email)
  end

  test "update_password" do
    assert_email(user: users(:active_user), template: :update_password)
  end

  private

  def assert_email(user:, template:)
    mailer_with(user).public_send(template).tap do |mail|
      assert_equal subject(template), mail.subject
      assert_equal [user.email], mail.to
      assert_match opening(template), mail.body.encoded
    end
  end

  def mailer_with(user)
    MinimalistAuthenticationMailer.with(user: user)
  end

  def opening(template)
    I18n.t("minimalist_authentication_mailer.#{template}.opening")
  end

  def subject(template)
    I18n.t("minimalist_authentication_mailer.#{template}.subject")
  end
end
