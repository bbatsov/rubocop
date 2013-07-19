# encoding: utf-8

module Rubocop
  module AutoCorrection
    # Automatically corrects offences generated by the Cop::Style::AndOr cop.
    # Replaces occurrence of "and" and "or" with "&&" and "||" respectively.
    class AndOr
      Registry.register 'AndOr', new

      def call(corrector, node)
        replacement = (node.type == :and ? '&&' : '||')
        corrector.replace(node.loc.operator, replacement)
      end
    end
  end
end
