# frozen_string_literal: true

module RuboCop
  module Cop
    # Functions for checking the alignment of the `end` keyword.
    module EndKeywordAlignment
      include ConfigurableEnforcedStyle
      include RangeHelp

      MSG = '`end` at %<end_line>d, %<end_col>d is not aligned with ' \
            '`%<source>s` at %<align_line>d, %<align_col>d.'.freeze

      private

      def add_offense_for_misalignment(node, align_with)
        end_loc = node.loc.end
        msg = format(MSG, end_line: end_loc.line,
                          end_col: end_loc.column,
                          source: align_with.source,
                          align_line: align_with.line,
                          align_col: align_with.column)
        add_offense(node, location: end_loc, message: msg)
      end

      def check_end_kw_alignment(node, align_ranges)
        return if ignored_node?(node)

        end_loc = node.loc.end
        return unless end_loc # Discard modifier forms of if/while/until.

        matching = matching_ranges(end_loc, align_ranges)

        if matching.key?(style)
          correct_style_detected
        else
          add_offense_for_misalignment(node, align_ranges[style])
          style_detected(matching.keys)
        end
      end

      def check_end_kw_in_node(node)
        check_end_kw_alignment(node, style => node.loc.keyword)
      end

      def line_break_before_keyword?(whole_expression, rhs)
        rhs.first_line > whole_expression.line
      end

      def matching_ranges(end_loc, align_ranges)
        align_ranges.select do |_, range|
          range.line == end_loc.line ||
            column_offset_between(range, end_loc).zero?
        end
      end

      def style_parameter_name
        'EnforcedStyleAlignWith'
      end

      def variable_alignment?(whole_expression, rhs, end_alignment_style)
        return if end_alignment_style == :keyword

        !line_break_before_keyword?(whole_expression, rhs)
      end
    end
  end
end
