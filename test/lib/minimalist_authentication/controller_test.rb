# frozen_string_literal: true

require "test_helper"

class ControllerTest < ActiveSupport::TestCase
  def self.helper_method(*args)
    # stub so MinimalistAuthentication::Controller include will work
  end

  def self.before_action(*args)
    # stub so MinimalistAuthentication::Controller include will work
  end

  include MinimalistAuthentication::Controller

  test "should return guest for current_user" do
    assert_equal "guest", current_user.email
  end

  test "should return logged_in user for current_user" do
    session[:user_id] = users(:active_user).id

    assert_equal users(:active_user), current_user
  end

  test "should not return inactive logged_in user for current_user" do
    users(:active_user).update_column(:active, false)
    session[:user_id] = users(:active_user).id

    assert_predicate current_user, :guest?
  end

  test "should pass authorization" do
    session[:user_id] = users(:active_user).id

    assert authorization_required
  end

  test "should fail authorization" do
    assert_equal new_session_path, authorization_required
  end

  test "should store location" do
    store_location

    assert_equal "/tests/new.html", session["return_to"]
  end

  private

  def action_name
    nil
  end

  def controller_name
    nil
  end

  def new_session_path
    "/session/new"
  end

  def redirect_to(path = nil)
    @redirect_to = path if path
    @redirect_to
  end

  def request
    mock.tap do |object|
      object.stubs(get?: true, params: { controller: "tests", action: "new" })
    end
  end

  def session
    @session ||= {}
  end

  def url_for(options)
    "/#{options[:controller]}/#{options[:action]}.#{options[:format]}"
  end
end
