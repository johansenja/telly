require "test_helper"

module Telly
  class ConstantControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get show" do
      get constant_show_url
      assert_response :success
    end
  end
end
