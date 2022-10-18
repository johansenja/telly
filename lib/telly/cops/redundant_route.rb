require "active_support/core_ext/string/inflections"

module Telly
  module Cops
    class RedundantRoute < RuboCop::Cop::Base
      MSG = "Cannot find `%<action_name>s` action in `%<controller_name>s`"
      MATCHER_NAMES = {
        get: :match_get?,
        post: :match_post?,
        put: :match_put?,
        patch: :match_patch?,
        delete: :match_delete?,
      }.freeze
      RESTRICT_ON_SEND = MATCHER_NAMES.keys

      MATCHER_NAMES.each do |method, matcher_name|
        def_node_matcher matcher_name, <<~PATTERN
                           (send nil? :#{method} $_ $(hash ...) ?)
                         PATTERN
      end

      def on_new_investigation
        @skip = !processed_source.file_path.to_s.match?(%r(config/routes(/[^/]+)?\.rb\z))
      end

      def on_send(node)
        return if @skip

        check = lambda do |path_node, options_node|
          next unless within_routes?(node)

          options_node = path_node.hash_type? ? path_node : options_node.first

          if options_node.nil?
            action_name = path_node.value.to_s.gsub(%r{\A/}, "")
            controller_name = find_controller_name(node)
          else
            to_value = find_in_hash(options_node, :to)

            if to_value
              controller_short_name, action_name = to_value.split("#")
              controller_name = "#{controller_short_name.camelize}Controller"
            else
              # not much we can do
              next
            end
          end

          if controller_name && action_name
            method = Telly.client.method(controller_name, action_name)

            if method
              # all good! No problems
            else
              add_offense node, message: format(
                      MSG,
                      action_name: action_name,
                      controller_name: controller_name,
                    )
            end
          else
            # not a lot we can do - maybe report a different error?
            next
          end
        end

        MATCHER_NAMES.each_value do |n|
          send(n, node, &check)
        end
      end

      private

      def_node_matcher :routes_draw?, <<~PATTERN
                         (send (send _ :routes) :draw)
                       PATTERN

      def within_routes?(node)
        node.each_ancestor(:block).any? { |a| routes_draw?(a.send_node) } || true
      end

      def_node_matcher :resource?, <<~PATTERN
                         (send nil :resources $_)
                       PATTERN

      def_node_matcher :namespace?, <<~PATTERN
                         (send nil :namespace $_)
                       PATTERN

      def find_controller_name(node)
        resource_name = nil
        namespaces = []

        node.each_ancestor(:block) do |a|
          n = a.send_node

          if !resource_name
            resource?(n) do |resource_name_node|
              resource_name = resource_name_node.value.to_s
            end
          end

          namespace?(n) do |namespace_name_node|
            namespaces.push namespace_name_node.value.to_s
          end
        end

        return nil unless resource_name

        full_namespace = namespaces.reduce("") { |all, n| "#{n.camelize}::#{all}" }

        "#{full_namespace}::#{controller.camelize}"
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
