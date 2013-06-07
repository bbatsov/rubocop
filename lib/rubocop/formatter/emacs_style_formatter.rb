# encoding: utf-8

module Rubocop
  module Formatter
    class EmacsStyleFormatter < SimpleTextFormatter
      def report_file(file, offences)
        offences.each do |o|
          output.printf("%s:%d:%d: %s: %s\n",
                        file, o.line, o.column, o.encode_severity, o.message)
        end
      end
    end
  end
end
