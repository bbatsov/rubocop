# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Some common code shared between the two cops.
      module FavorOtherKeywordOverNegation
        def check(node)
          condition, _body, _rest = *node

          # Look at last expression of contents if there's a parenthesis
          # around condition.
          condition = condition.children.last while condition.type == :begin

          if condition.type == :send
            _object, method = *condition
            if method == :! && !(node.loc.respond_to?(:else) && node.loc.else)
              add_offence(:convention, node.loc.expression, error_message)
            end
          end
        end
      end

      # Checks for uses of if with a negated condition. Only ifs
      # without else are considered.
      class FavorUnlessOverNegatedIf < Cop
        include FavorOtherKeywordOverNegation

        def on_if(node)
          check(node)
        end

        def error_message
          'Favor unless (or control flow or) over if for negative conditions.'
        end
      end

      # Checks for uses of while with a negated condition.
      class FavorUntilOverNegatedWhile < Cop
        include FavorOtherKeywordOverNegation

        def on_while(node)
          check(node)
        end

        def error_message
          'Favor until over while for negative conditions.'
        end
      end
    end
  end
end
