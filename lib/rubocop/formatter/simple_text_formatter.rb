# encoding: utf-8

module Rubocop
  module Formatter
    # A basic formatter that displays only files with offences.
    # Offences are displayed at compact form - just the
    # location of the problem and the associated message.
    class SimpleTextFormatter < BaseFormatter
      def started(target_files)
        @total_offence_count = 0
      end

      def file_finished(file, offences)
        return if offences.empty?
        @total_offence_count += offences.count
        report_file(file, offences)
      end

      def finished(inspected_files)
        report_summary(inspected_files.count, @total_offence_count)
      end

      def report_file(file, offences)
        output.puts "== #{smart_path(file)} ==".color(:yellow)
        output.puts offences.join("\n")
      end

      def report_summary(file_count, offence_count)
        summary = ''

        plural = file_count == 0 || file_count > 1 ? 's' : ''
        summary << "#{file_count} file#{plural} inspected, "

        offences_string = case offence_count
                          when 0 then 'no offences'
                          when 1 then '1 offence'
                          else "#{offence_count} offences"
                          end
        summary << "#{offences_string} detected"
          .color(offence_count.zero? ? :green : :red)

        output.puts
        output.puts summary
      end

      protected

      def smart_path(path)
        if path.start_with?(Dir.pwd)
          Pathname.new(path).relative_path_from(Pathname.getwd).to_s
        else
          path
        end
      end
    end
  end
end
