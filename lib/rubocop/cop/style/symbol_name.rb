# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks whether symbol names are snake_case.
      # There's also an option to accept CamelCase symbol names as well.
      class SymbolName < Cop
        MSG = 'Use snake_case for symbols.'
        SNAKE_CASE = /^[\da-z_]+[!?=]?$/
        CAMEL_CASE = /^[A-Z][A-Za-z\d]*$/

        def allow_camel_case?
          self.class.config['AllowCamelCase']
        end

        def on_send(node)
          receiver, method_name, *args = *node
          # Arguments to Module#private_constant are symbols referring to
          # existing constants, so they will start with an upper case letter.
          # We ignore these symbols.
          if receiver.nil? && method_name == :private_constant
            args.each { |a| ignore_node(a) }
          end
        end

        def on_sym(node)
          return if ignored_node?(node)
          sym_name = node.to_a[0]
          return unless sym_name =~ /^[a-zA-Z]/
          return if sym_name =~ SNAKE_CASE
          return if allow_camel_case? && sym_name =~ CAMEL_CASE
          add_offence(:convention, node.loc.expression, MSG)
        end
      end
    end
  end
end
