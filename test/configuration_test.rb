require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  test 'should set default user_model' do
    assert_equal ::User, configuration.user_model
  end

  test 'should set default session_key' do
    assert_equal :user_id, configuration.session_key
  end

  test 'should configure options' do
    test_class = Class.new

    MinimalistAuthentication.configure do |configuration|
      configuration.user_model  = test_class
      configuration.session_key = :test_key
    end

    assert_equal test_class,  MinimalistAuthentication.configuration.user_model
    assert_equal :test_key,   MinimalistAuthentication.configuration.session_key

    MinimalistAuthentication.reset_configuration!
  end

  private

  def configuration
    MinimalistAuthentication::Configuration.new
  end
end
