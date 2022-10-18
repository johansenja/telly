module Telly
  class ApplicationController < ActionController::Base
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    def not_found
      raise ActionController::RoutingError.new("Not Found")
    end
  end
end
