# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking for space before
    # punctuation.
    module SpaceBeforePunctuation
      include RangeHelp

      MSG = 'Space found before %<token>s.'
      SPACE_INSIDE_PARENS_STYLES = %w[space compact].freeze

      def on_new_investigation
        each_missing_space(processed_source.sorted_tokens) do |token, pos_before|
          add_offense(pos_before, message: format(MSG, token: kind(token))) do |corrector|
            PunctuationCorrector.remove_space(corrector, pos_before)
          end
        end
      end

      private

      def each_missing_space(tokens)
        tokens.each_cons(2) do |token1, token2|
          next unless kind(token2)
          next unless space_missing?(token1, token2)
          next if space_required_after?(token1)

          pos_before_punctuation = range_between(token1.end_pos, token2.begin_pos)

          yield token2, pos_before_punctuation
        end
      end

      def space_missing?(token1, token2)
        same_line?(token1, token2) && token2.begin_pos > token1.end_pos
      end

      def space_required_after?(token)
        return space_required_after_lcurly? if token.left_curly_brace?
        return space_required_after_lparen? if token.left_parens?

        false
      end

      def space_required_after_lcurly?
        cfg = config.for_cop('Layout/SpaceInsideBlockBraces')
        style = cfg['EnforcedStyle'] || 'space'
        style == 'space'
      end

      def space_required_after_lparen?
        style = config.for_enabled_cop('Layout/SpaceInsideParens')['EnforcedStyle']

        SPACE_INSIDE_PARENS_STYLES.include?(style)
      end
    end
  end
end
