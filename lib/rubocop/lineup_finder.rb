# frozen_string_literal: true

# require 'set'

module RuboCop
  # This class finds changed files by parsing git changes
  class LineupFinder
    attr_reader :diff_info

    def changed_files
      @changed_files ||=
        git_diff_name_only
        .lines
        .map(&:chomp)
        .grep(/\.rb$/)
        .map { |file| File.absolute_path(file) }
    end

    def changed_files_and_lines
      @diff_info ||= Hash[
        changed_files.collect do |file|
          [file, changed_line_ranges(file)]
        end
      ]

      @changes ||= Hash[
        diff_info.collect do |filename, changed_line_ranges|
          [filename, line_ranges_to_mask(changed_line_ranges)]
        end
      ]
    end

    private

    def git_diff_name_only
      `git diff --diff-filter=AM --name-only HEAD`
    end

    def git_diff_zero_unified(file)
      `git diff -U0 HEAD #{file}`
    end

    def changed_line_ranges(file)
      git_diff_zero_unified(file)
        .each_line
        .grep(/@@ -(\d+)(?:,)?(\d+)? \+(\d+)(?:,)?(\d+)? @@/) do
          [
            Regexp.last_match[3].to_i,
            (Regexp.last_match[4] || 1).to_i
          ]
        end
    end

    def line_ranges_to_mask(line_ranges)
      line_ranges.collect do |line_range_start, number_of_changed_lines|
        if number_of_changed_lines.zero?
          []
        else
          line_range_end = line_range_start + number_of_changed_lines - 1
          Array(line_range_start..line_range_end)
        end
      end.flatten
    end
  end
end
