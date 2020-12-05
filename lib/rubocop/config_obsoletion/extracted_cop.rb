# frozen_string_literal: true

module RuboCop
  class ConfigObsoletion
    # Encapsulation of a ConfigObsoletion rule for splitting a cop's
    # functionality into multiple new cops.
    # @api private
    class ExtractedCop < CopRule
      attr_reader :gem, :department

      def initialize(config, old_name, gem)
        super(config, old_name)
        @department, * = old_name.rpartition('/')
        @gem = gem
      end

      def violated?
        return false if gem_installed?

        affected_gems.any?
      end

      def rule_message
        msg = '%<name>s been extracted to the `%<gem>s` gem.'
        format(msg,
               name: affected_gems.size > 1 ? "`#{department}` cops have" : "`#{old_name}` has",
               gem: gem)
      end

      private

      def affected_gems
        return old_name unless old_name.end_with?('*')

        # Handle whole departments (expressed as `Department/*`)
        config.keys.grep(Regexp.new("^#{department}"))
      end

      def gem_installed?
        Lockfile.new.includes_gem?(gem)
      end
    end
  end
end
