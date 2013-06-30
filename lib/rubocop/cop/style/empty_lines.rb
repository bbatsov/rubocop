# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for two or more consecutive blank lines.
      class EmptyLines < Cop
        MSG = 'Extra blank line detected.'
        LINE_OFFSET = 2

        def inspect(source_buffer, source, tokens, ast, comments)
          return if tokens.empty?

          prev_line = 1

          tokens.each do |token|
            cur_line = token.pos.line
            line_diff = cur_line - prev_line

            if line_diff > LINE_OFFSET
              # we need to be wary of comments since they
              # don't show up in the tokens
              ((prev_line + 1)...cur_line).each do |line|
                # we check if the prev and current lines are empty
                if source[line - 2].empty? && source[line - 1].empty?
                  add_offence(:convention,
                              source_range(source_buffer,
                                           source[0...(line - 1)], 0, 1),
                              MSG)
                end
              end
            end

            prev_line = cur_line
          end
        end
      end
    end
  end
end
