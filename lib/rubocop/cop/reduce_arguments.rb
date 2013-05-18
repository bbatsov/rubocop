# encoding: utf-8

module Rubocop
  module Cop
    class ReduceArguments < Cop
      MSG = 'Name reduce arguments |a, e| (accumulator, element)'

      ARGS_NODE = s(:args, s(:arg, :a), s(:arg, :e))

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:block, sexp) do |node|
          # we care only for single line blocks
          next unless Util.block_length(node) == 0

          method_node, args_node, _body_node = *node
          receiver, method_name, _method_args = *method_node

          # discard other scenarios
          next unless receiver
          next unless [:reduce, :inject].include?(method_name)

          unless args_node == ARGS_NODE
            add_offence(:convention, node.src.line, MSG)
          end
        end
      end
    end
  end
end
