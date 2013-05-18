# encoding: utf-8

module Rubocop
  module Cop
    class HandleExceptions < Cop
      MSG = 'Do not suppress exceptions.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:resbody, sexp) do |node|
          _exc_list_node, _exc_var_node, body_node = *node

          add_offence(:warning,
                      node.src.line,
                      MSG) if body_node.type == :nil
        end
      end
    end
  end
end
