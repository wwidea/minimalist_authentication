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

    assert current_user.is_guest?
  end

  test "should pass authorization" do
    session[:user_id] = users(:active_user).id

    assert_equal true, authorization_required
  end

  test "should fail authorization" do
    assert_equal new_session_path, authorization_required
  end

  test "should store location" do
    store_location

    assert_equal request.fullpath, session["return_to"]
  end

  test "should redirect to stored location" do
    store_location
    redirect_back_or_default("/")

    assert_equal request.fullpath, redirect_to
  end

  test "should redirect to stored location only once" do
    store_location
    redirect_back_or_default("/")

    assert_equal request.fullpath, redirect_to
    redirect_back_or_default("/")

    assert_equal "/", redirect_to
  end

  test "should redirect to default" do
    redirect_back_or_default("/")

    assert_equal "/", redirect_to
  end


  private

  def redirect_to(path = nil)
    @redirect_to = path if path
    return @redirect_to
  end

  def session
    @session ||= Hash.new
  end

  def action_name
    nil
  end

  def controller_name
    nil
  end

  def new_session_path
    "/session/new"
  end

  def request
    (Class.new do
      def method
        :get
      end

      def fullpath
        "http://www.example.com"
      end
    end).new
  end
end
