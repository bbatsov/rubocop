# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of double quotes where single quotes would do.
      class StringLiterals < Cop
        MSG = "Prefer single-quoted strings when you don't need " +
          'string interpolation or special symbols.'

        def on_str(node)
          # Constants like __FILE__ are handled as strings,
          # but don't respond to begin.
          return unless node.loc.respond_to?(:begin)
          return if part_of_ignored_node?(node)

          # regex matches IF there is a ' or there is a \\ in the string that
          # is not preceeded/followed by another \\ (e.g. "\\x34") but not
          # "\\\\"
          if node.loc.expression.source !~ /('|([^\\]|\A)\\([^\\]|\Z))/ &&
              node.loc.begin.is?('"')
            add_offence(:convention, node.loc.expression, MSG, node: node)
          end
        end

        alias_method :on_dstr, :ignore_node
        alias_method :on_regexp, :ignore_node
      end
    end
  end
end
