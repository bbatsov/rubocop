# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant returning of true/false in conditionals.
      #
      # @example
      #   # bad
      #   x == y ? true : false
      #
      #   # bad
      #   if x == y
      #     true
      #   else
      #     false
      #   end
      #
      #   # good
      #   x == y
      #
      #   # bad
      #   x == y ? false : true
      #
      #   # good
      #   x != y
      #
      # @api private
      class RedundantConditional < Cop
        include Alignment

        operators = RuboCop::AST::Node::COMPARISON_OPERATORS.to_a
        COMPARISON_OPERATOR_MATCHER = "{:#{operators.join(' :')}}"

        MSG = 'This conditional expression can just be replaced ' \
              'by `%<msg>s`.'

        def on_if(node)
          return unless offense?(node)

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node, replacement_condition(node))
          end
        end

        private

        def message(node)
          replacement = replacement_condition(node)
          msg = node.elsif? ? "\n#{replacement}" : replacement

          format(MSG, msg: msg)
        end

        def_node_matcher :redundant_condition?, <<~RUBY
          (if (send _ #{COMPARISON_OPERATOR_MATCHER} _) true false)
        RUBY

        def_node_matcher :redundant_condition_inverted?, <<~RUBY
          (if (send _ #{COMPARISON_OPERATOR_MATCHER} _) false true)
        RUBY

        def offense?(node)
          return if node.modifier_form?

          redundant_condition?(node) || redundant_condition_inverted?(node)
        end

        def replacement_condition(node)
          condition = node.condition.source
          expression = invert_expression?(node) ? "!(#{condition})" : condition

          node.elsif? ? indented_else_node(expression, node) : expression
        end

        def invert_expression?(node)
          (
            (node.if? || node.elsif? || node.ternary?) &&
            redundant_condition_inverted?(node)
          ) || (
            node.unless? &&
            redundant_condition?(node)
          )
        end

        def indented_else_node(expression, node)
          "else\n#{indentation(node)}#{expression}"
        end

        def configured_indentation_width
          super || 2
        end
      end
    end
  end
end
