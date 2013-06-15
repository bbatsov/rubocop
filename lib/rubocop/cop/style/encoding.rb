# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class Encoding < Cop
        MSG = 'Missing utf-8 encoding comment.'

        def inspect(source_buffer, source, tokens, ast, comments)
          unless RUBY_VERSION >= '2.0.0'
            expected_line = 0
            expected_line += 1 if source[expected_line] =~ /^#!/
            unless source[expected_line] =~ /#.*coding: (UTF|utf)-8/
              add_offence(:convention, Location.new(1, 0, source), MSG)
            end
          end
        end
      end
    end
  end
end
