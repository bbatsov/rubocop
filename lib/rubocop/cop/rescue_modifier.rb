# encoding: utf-8

module Rubocop
  module Cop
    class RescueModifier < Cop
      MSG = 'Avoid using rescue in its modifier form.'

      def inspect(source, tokens, ast, comments)
        on_node(:rescue, ast, :begin) do |s|
          add_offence(:convention,
                      s.loc.line,
                      MSG)
        end
      end
    end
  end
end
