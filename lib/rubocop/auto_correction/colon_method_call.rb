# encoding: utf-8

module Rubocop
  module AutoCorrection
    # Automatically corrects offences generated by the
    # Cop::Style::ColonMethodCall cop.
    # Replaces "test::method" with "test.method"
    class ColonMethodCall
      Registry.register 'ColonMethodCall', self

      def call(corrector, node)
        corrector.replace(node.loc.dot, '.')
      end
    end
  end
end
