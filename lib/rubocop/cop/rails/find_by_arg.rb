# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of `find_by(arg)` and
      # change them to use `find_by(column: arg)` instead.
      #
      # @example
      #   # bad
      #   User.find_by(1)
      #
      #   # good
      #   User.find_by(id: 1)
      class FindByArg < Cop
        MSG = '`find_by(arg)` may not work.' \
              'Use `find_by(column: arg)` instead.'.freeze
        METHODS = [:find_by, :find_by!]

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless METHODS.any? { |method| method == method_name }
          return if args.all? { |arg| arg.hash_type? }
          add_offense(node, :expression)
        end
      end
    end
  end
end
