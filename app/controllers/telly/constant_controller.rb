module Telly
  class ConstantController < ApplicationController
    def show
      const_name = params[:id]

      begin
        const = const_name.constantize
      rescue NameError
        raise ActiveRecord::RecordNotFound
      end

      file_name, line_number = Object.const_source_location(const_name)

      location = nil

      if file_name && line_number
        location = {
          file: file_name,
          line: line_number,
        }
      end

      render json: {
        name: const.name,
        location: location,
      }
    end
  end
end
