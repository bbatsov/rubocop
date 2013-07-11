# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks the . position in multi-line method calls.
      class DotPosition < Cop
        MSG = 'Place the . on the next line, together with the method name.'

        def on_send(node)
          return unless node.loc.dot

          unless proper_dot_position?(node)
            add_offence(:convention, node.loc.dot, MSG)
          end
        end

        private

        def proper_dot_position?(node)
          dot_line = node.loc.dot.line
          selector_line = node.loc.selector.line

          case DotPosition.config['Style'].downcase
          when 'leading' then dot_line == selector_line
          when 'trailing' then dot_line != selector_line
          else fail 'Unknown dot position style selected.'
          end
        end
      end
    end
  end
end
