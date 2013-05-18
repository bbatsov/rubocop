# encoding: utf-8

module Rubocop
  module Cop
    class WhenThen < Cop
      MSG = 'Never use "when x;". Use "when x then" instead.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:when, sexp) do |s|
          if s.src.begin && s.src.begin.to_source == ';'
            add_offence(:convention, s.src.line, MSG)
          end
        end
      end
    end
  end
end
