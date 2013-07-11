# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks whether the block arguments of a single-line
      # reduce(inject) call are named *a*(for accumulator) and *e*
      # (for element)
      class ReduceArguments < Cop
        MSG = 'Name reduce arguments |a, e| (accumulator, element).'

        ARGS_NODE = s(:args, s(:arg, :a), s(:arg, :e))

        def on_block(node)
          # we care only for single line blocks
          return unless Util.block_length(node) == 0

          method_node, args_node, _body_node = *node
          receiver, method_name, _method_args = *method_node

          # discard other scenarios
          return unless receiver
          return unless [:reduce, :inject].include?(method_name)

          unless args_node == ARGS_NODE
            add_offence(:convention, node.loc.expression, MSG)
          end
        end
      end
    end
  end
end
