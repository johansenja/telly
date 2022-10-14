require "test_helper"

module Telly
  class MethodControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get show" do
      get method_show_url
      assert_response :success
    end
  end
end
