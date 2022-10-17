module Telly
  class ReflectionController < ApplicationController
    def show
      model_name = params[:model_id]

      const = Telly::Model.find_by_name(model_name) or raise ActiveRecord::RecordNotFound

      reflection = const.reflections[params[:id].to_s] or raise ActiveRecord::RecordNotFound

      const_file_name, const_line_number = Object.const_source_location(const_name)
      if const_file_name && const_line_number
        const_location = {
          file: const_file_name,
          line: const_line_number,
        }
      end

      to_model = reflection.klass

      render json: {
        constant: {
          name: const.name,
          location: const_location,
        },
        reflection: {
          name: reflection.name.to_s,
          plural_name: reflection.plural_name,
          type: reflection_type(reflection),
          to_model: to_model.name,
          table_name: to_model.table_name,
          foreign_key: reflection.foreign_key,
          primary_key: reflection.options.fetch(:primary_key, :id), # TODO: can :id be dynamic?
        },
      }
    end

    private

    def reflection_type(refl)
      case refl
      when ActiveRecord::Reflection::BelongsToReflection
        :belongs_to
      when ActiveRecord::Reflection::HasOneReflection
        :has_one
      when ActiveRecord::Reflection::HasManyReflection
        :has_many
      end
    end
  end
end
