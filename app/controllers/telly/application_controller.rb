module Telly
  class ApplicationController < ActionController::Base
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
  end
end
