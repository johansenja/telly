module Telly
  class ColumnController < ApplicationController
    def show
      const_name = params[:model_id]

      const = Telly::Model.find_by_name(const_name) or raise ActiveRecord::RecordNotFound

      begin
        columns = const.columns
      rescue ActiveRecord::TableNotSpecified
        raise ActiveRecord::RecordNotFound
      end

      column = columns.find { |c| c.name == params[:id].to_s } or raise ActiveRecord::RecordNotFound

      file_name, line_number = Object.const_source_location(const_name)

      if file_name && line_number
        location = {
          file: file_name,
          line: line_number,
        }
      end

      render json: {
        model: {
          name: const.name,
          location: location,
        },
        column: {
          name: column.name,
          comment: column.comment,
          nullable: column.null,
          default: column.default,
          default_function: column.default_function,
          collation: column.collation,
          serial: column.serial,
          type: {
            sql_type: column.sql_type_metadata.sql_type,
            rails_type: column.sql_type_metadata.type,
          },
        },
      }
    end
  end
end
