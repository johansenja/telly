module Telly
  class ModelController < ApplicationController
    def show
      const_name = params[:id]

      const = Telly::Model.find_by_name(const_name) or raise ActiveRecord::RecordNotFound

      file_name, line_number = Object.const_source_location(const_name)

      location = nil

      if file_name && line_number
        location = {
          file: file_name,
          line: line_number,
        }
      end

      table_name = begin
          const.table_name
        rescue ActiveRecord::TableNotSpecified
          nil
        end

      render json: {
        name: const.name,
        location: location,
        table_name: table_name,
      }
    end
  end
end
