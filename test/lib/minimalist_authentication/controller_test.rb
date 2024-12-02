# frozen_string_literal: true

require "test_helper"

class ControllerTest < ActiveSupport::TestCase
  class << self
    # Stub included block methods
    def stub(*) = nil
    alias before_action stub
    alias helper stub
    alias helper_method stub
  end

  include MinimalistAuthentication::Controller

  test "should call store_location and redirect_to new_session_path for access_denied" do
    expects(:store_location).returns(true)
    access_denied

    assert_equal new_session_path, redirect_to
  end

  test "should return true for authorization_required when user is logged in" do
    expects(:logged_in?).returns(true)

    assert authorization_required
  end

  test "should call access_denied when user is not authorized" do
    expects(:access_denied).returns("access_denied")

    assert_equal "access_denied", authorization_required
  end

  test "should return session user for current_user" do
    session[MinimalistAuthentication.session_key] = users(:active_user).id
    load_current_user

    assert_equal users(:active_user), current_user
  end

  test "should return nil for current_user when session_key is missing" do
    load_current_user

    assert_nil current_user
  end

  test "should return nil for current_user when session user is not active" do
    users(:active_user).update_column(:active, false)
    session[:user_id] = users(:active_user).id

    assert_nil current_user
  end

  test "should set current user from session for load_current_user" do
    session[MinimalistAuthentication.session_key] = users(:active_user).id

    assert_equal users(:active_user), load_current_user
    assert_equal users(:active_user), Current.user
  end

  test "should set current user to nil for load_current_user when session key is missing" do
    assert_nil load_current_user
    assert_nil Current.user
  end

  test "should return true for logged_in? when current user is present" do
    Current.user = users(:active_user)

    assert_predicate self, :logged_in?
  end

  test "should return false for logged_in? when current user is nil" do
    assert_not_predicate self, :logged_in?
  end

  test "should store current url in the session for store_location" do
    store_location

    assert_equal "/tests/new.html", session["return_to"]
  end

  test "should reset session and set current user for update_current_user" do
    session[:foo] = "bar"
    update_current_user(users(:active_user))

    assert_equal({ user_id: users(:active_user).id }, session)
    assert_equal users(:active_user), Current.user
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

  def reset_session
    @session = nil
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
