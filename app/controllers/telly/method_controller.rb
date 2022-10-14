module Telly
  class MethodController < ApplicationController
    def show
      const_name = params[:constant_id]

      # TODO: consolidate with logic in ConstantController
      begin
        const = const_name.constantize
      rescue NameError
        raise ActiveRecord::RecordNotFound
      end

      begin
        meth = const.instance_method(params[:id].to_sym)
      rescue NameError
        raise ActiveRecord::RecordNotFound
      end

      const_file_name, const_line_number = Object.const_source_location(const_name)
      meth_file_name, meth_line_number = meth.source_location

      const_location = nil
      meth_location = nil

      if const_file_name && const_line_number
        const_location = {
          file: const_file_name,
          line: const_line_number,
        }
      end

      if meth_file_name && meth_line_number
        meth_location = {
          file: meth_file_name,
          line: meth_line_number,
        }
      end

      render json: {
        constant: {
          name: const.name,
          location: const_location,
        },
        method: {
          name: meth.name,
          arity: meth.arity,
          location: meth_location,
        },
      }
    end
  end
end
