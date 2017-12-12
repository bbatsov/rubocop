# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks if empty lines exist around the arguments
      # of a method invocation.
      #
      # @example
      #   # bad
      #   do_something(
      #     foo
      #
      #   )
      #
      #   process(bar,
      #
      #           baz: qux,
      #           thud: fred)
      #
      #   some_method(
      #
      #     [1,2,3],
      #     x: y
      #   )
      #
      #   # good
      #   do_something(
      #     foo
      #   )
      #
      #   process(bar,
      #           baz: qux,
      #           thud: fred)
      #
      #   some_method(
      #     [1,2,3],
      #     x: y
      #   )
      #
      class EmptyLinesAroundArguments < Cop
        MSG = 'Empty line detected around arguments.'.freeze

        def on_send(node)
          return if node.single_line?
          return if empty_lines(node).empty?
          extra_lines(node) { |range| add_offense(node, location: range) }
        end

        def autocorrect(node)
          lambda do |corrector|
            extra_lines(node) { |range| corrector.remove(range) }
          end
        end

        private

        def empty_lines(node)
          @empty_lines ||= begin
            lines = source_lines(node).map.with_index(1).to_a
            lines.select! { |code, _| code == '' }
            lines.map { |_, line| line }
          end
        end

        def source_lines(node)
          source =
            if node.arguments.last && node.arguments.last.block_type?
              source_without_block(node, node.arguments.last)
            else
              node.source
            end
          source.lines.map { |line| line.delete("\n") }
        end

        def extra_lines(node)
          empty_lines(node).each do |line|
            range = source_range(processed_source.buffer, line, 0)
            yield(range)
          end
        end

        def source_without_block(node, block_node)
          node.source.split(block_node.source).first
        end
      end
    end
  end
end
