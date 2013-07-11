# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks whether comments have a leading space
      # after the # denoting the start of the comment. The
      # leading space is not required for some RDoc special syntax,
      # like #++, #--, #:nodoc, etc.
      class LeadingCommentSpace < Cop
        MSG = 'Missing space after #.'

        def investigate(source_buffer, source, tokens, ast, comments)
          comments.each do |comment|
            if comment.text =~ /^#+[^#\s:+-]/
              unless comment.text.start_with?('#!') && comment.loc.line == 1
                add_offence(:convention, comment.loc, MSG)
              end
            end
          end
        end
      end
    end
  end
end
