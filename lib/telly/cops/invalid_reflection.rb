require "active_support/core_ext/string/inflections"

module Telly
  module Cops
    class InvalidReflection < RuboCop::Cop::Base
      MATCHER_NAMES = {
        belongs_to: :match_belongs_to?,
        has_many: :match_has_many?,
        has_one: :match_has_one?,
      }.freeze
      RESTRICT_ON_SEND = MATCHER_NAMES.keys

      NON_MATCHING_KEY_TYPES_MSG = "Primary key (`%<pk>s`) type (`%<pk_type>s`) doesn't match foreign key (`%<fk>s`) type (`%<fk_type>s`)"
      NO_ASSOCIATED_COLUMN_MSG = "No column exists in the DB for the `%<type>s` `%<name>s`"
      NO_MODEL_MSG = "No ActiveRecord model exists for `%<reflection_name>s` (expected to find `%<expected>s`)"
      NO_DB_TABLE_MSG = "No table exists in the DB for `%<reflection_name>s`'s model"

      MATCHER_NAMES.each do |method, matcher_name|
        def_node_matcher matcher_name, <<~PATTERN
                           (send nil? :#{method} $_ $(hash ...) ?)
                         PATTERN
      end

      def on_new_investigation
        @skip = !processed_source.file_path.to_s.match?(%r(app/models/[^/]+\.rb\z))
      end

      def on_send(node)
        return if @skip

        check = lambda do |association_node, kw_node|
          next unless within_model?(node)

          kw_node = association_node.hash_type? ? association_node : kw_node.first

          if kw_node
            primary_key = find_in_hash(kw_node, :primary_key)
            foreign_key = find_in_hash(kw_node, :foreign_key)
            other_model_name = find_in_hash(kw_node, :class_name)&.to_s
          end

          reflection_name = association_node.value.to_s

          other_model_name ||= reflection_name.singularize.camelize

          other_model_obj = Telly.client.model(other_model_name)

          if !other_model_obj
            add_offense(
              node, message: format(
                      NO_MODEL_MSG,
                      reflection_name: reflection_name,
                      expected: other_model_name,
                    ),
            )
          elsif !other_model_obj["table_name"]
            add_offense(node, message: format(
                                NO_DB_TABLE_MSG,
                                reflection_name: reflection_name,
                              ))
          end

          primary_key ||= :id
          foreign_key ||= :"#{reflection_name.singularize}_id"

          primary_key_column = Telly.client.column(other_model_name, primary_key)
          foreign_key_column = Telly.client.column(other_model_name, foreign_key)

          if !primary_key_column || !foreign_key_column
            unless primary_key_column
              add_offense(node, message: format(
                                  NO_ASSOCIATED_COLUMN_MSG,
                                  type: "primary key",
                                  name: "\"#{primary_key}\"",
                                ))
            end

            unless foreign_key_column
              add_offense(node, message: format(
                                  NO_ASSOCIATED_COLUMN_MSG,
                                  type: "foreign key",
                                  name: "\"#{foreign_key}\"",
                                ))
            end

            next
          end

          pk_type = primary_key_column.dig "column", "type", "sql_type"
          fk_type = foreign_key_column.dig "column", "type", "sql_type"

          if pk_type && pk_type != fk_type
            add_offense(node, message: format(
                                NON_MATCHING_KEY_TYPES_MSG,
                                pk: primary_key,
                                pk_type: pk_type,
                                fk: foreign_key,
                                fk_type: fk_type,
                              ))
          end
        end

        MATCHER_NAMES.each_value do |v|
          send(v, node, &check)
        end
      end

      private

      def within_model?(_node)
        # TODO: could actually make this more dynamic, but the likelihood of someone using a
        # reflection name in a model file outside the model is remote...
        true
      end

      def find_in_hash(node, key)
        val = nil

        node.each_pair do |k, v|
          next unless k.sym_type?

          next unless k.value == key

          next unless v.sym_type? || v.str_type?

          val = v.value
        end

        val
      end
    end
  end
end
