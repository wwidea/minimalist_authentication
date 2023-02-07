require "test_helper"

class ConfigurationTest < ActiveSupport::TestCase
  def setup
    MinimalistAuthentication.reset_configuration!
  end

  def teardown
    MinimalistAuthentication.reset_configuration!
  end

  test "should set default user_model" do
    assert_equal ::User, configuration.user_model
  end

  test "should set default session_key" do
    assert_equal :user_id, configuration.session_key
  end

  test "should configure options" do
    MinimalistAuthentication.configure do |configuration|
      configuration.user_model_name = "Object"
      configuration.session_key     = :test_key
    end

    assert_equal Object,    MinimalistAuthentication.configuration.user_model
    assert_equal :test_key, MinimalistAuthentication.configuration.session_key
  end

  private

  def configuration
    MinimalistAuthentication::Configuration.new
  end
end
