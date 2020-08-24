# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the use of the send method.
      #
      # @example
      #   # bad
      #   Foo.send(:bar)
      #   quuz.send(:fred)
      #
      #   # good
      #   Foo.__send__(:bar)
      #   quuz.public_send(:fred)
      #
      # @api private
      class Send < Base
        MSG = 'Prefer `Object#__send__` or `Object#public_send` to ' \
              '`send`.'

        def_node_matcher :sending?, '({send csend} _ :send ...)'

        def on_send(node)
          return unless sending?(node) && node.arguments?

          add_offense(node.loc.selector)
        end
        alias on_csend on_send
      end
    end
  end
end
