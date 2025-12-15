# frozen_string_literal: true

require "test_helper"

class LimitedCreationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    LimitedCreationsController.cache_store.clear
  end

  test "should redirect to new_session_path when rate_limit is exceeded" do
    10.times do
      post limited_creations_path

      assert_response :ok
    end

    post limited_creations_path

    assert_redirected_to new_session_path
    assert_equal I18n.t("limit_creations.alert"), flash[:alert]
  end
end
