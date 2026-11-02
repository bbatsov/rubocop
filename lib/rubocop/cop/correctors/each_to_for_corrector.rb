# frozen_string_literal: true

module RuboCop
  module Cop
    # This class autocorrects `#each` enumeration to `for` iteration.
    class EachToForCorrector
      extend NodePattern::Macros

      def initialize(block_node)
        @block_node = block_node
        @collection_node = block_node.receiver
        @argument_node = block_node.arguments
      end

      def call(corrector)
        corrector.insert_before(block_node, "for #{loop_variables} in ")
        corrector.replace(offending_range, opening_keyword)
        corrector.replace(block_node.loc.end, closing_keyword) if block_node.braces?
      end

      private

      attr_reader :block_node, :collection_node, :argument_node

      def loop_variables
        return '_' unless block_node.arguments?

        variables = argument_node.children.map { |argument| loop_variable(argument) }.join(', ')

        argument_node.source.match?(/,\s*\|\z/) ? "#{variables}," : variables
      end

      def loop_variable(argument)
        return argument.source unless argument.mlhs_type?

        variables = argument.children.map { |child| loop_variable(child) }.join(', ')
        lone_target = argument.children.one? && !argument.children.first.restarg_type?

        lone_target ? "(#{variables},)" : "(#{variables})"
      end

      def opening_keyword
        padding_needed?(offending_range.end_pos) ? ' do ' : ' do'
      end

      def closing_keyword
        padding_needed?(block_node.loc.end.begin_pos - 1) ? ' end' : 'end'
      end

      def padding_needed?(position)
        character = block_node.source_range.source_buffer.source[position]

        !character.nil? && !character.match?(/\s/)
      end

      def offending_range
        begin_range = collection_node.source_range.end

        if block_node.arguments?
          begin_range.join(argument_node.source_range.end)
        else
          begin_range.join(block_node.loc.begin.end)
        end
      end
    end
  end
end
