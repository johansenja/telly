module Telly
  class ApplicationController < ActionController::Base
    # must go first
    rescue_from StandardError, with: :handle_exception

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def not_found
      raise ActionController::RoutingError.new("Not Found")
    end

    def handle_exception(error)
      render json: { error: error.class, message: error.message }, status: 500
    end
  end
end
