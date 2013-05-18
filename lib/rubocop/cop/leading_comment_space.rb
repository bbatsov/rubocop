# encoding: utf-8

module Rubocop
  module Cop
    class LeadingCommentSpace < Cop
      MSG = 'Missing space after #.'

      def inspect(file, source, tokens, sexp)
        # TODO implemented when Parser starts tracking comments
      end
    end
  end
end
