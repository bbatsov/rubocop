# encoding: utf-8
require 'pathname'
require 'optparse'

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    DEFAULT_FORMATTER = 'progress'

    # If set true while running,
    # RuboCop will abort processing and exit gracefully.
    attr_accessor :wants_to_quit
    attr_accessor :options

    alias_method :wants_to_quit?, :wants_to_quit

    def initialize
      @cops = Cop::Cop.all
      @errors = []
      @options = {}
      @config_store = ConfigStore.new
    end

    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run(args = ARGV)
      trap_interrupt

      parse_options(args)

      Config.debug = @options[:debug]

      # filter out Rails cops unless requested
      @cops.reject!(&:rails?) unless @options[:rails]

      # filter out style cops when --lint is passed
      @cops.select!(&:lint?) if @options[:lint]

      target_files = target_finder.find(args)
      target_files.each(&:freeze).freeze
      inspected_files = []
      any_failed = false

      formatter_set.started(target_files)

      target_files.each do |file|
        break if wants_to_quit?

        puts "Scanning #{file}" if @options[:debug]
        formatter_set.file_started(file, {})

        offences = inspect_file(file)

        any_failed = true unless offences.empty?
        inspected_files << file
        formatter_set.file_finished(file, offences.freeze)
      end

      formatter_set.finished(inspected_files.freeze)
      formatter_set.close_output_files

      display_error_summary(@errors) unless @options[:silent]

      !any_failed && !wants_to_quit ? 0 : 1
    rescue => e
      $stderr.puts e.message
      return 1
    end

    def validate_only_option
      if @cops.none? { |c| c.cop_name == @options[:only] }
        fail ArgumentError, "Unrecognized cop name: #{@options[:only]}."
      end
    end

    def validate_auto_gen_config_option(args)
      if args.any?
        fail ArgumentError,
             '--auto-gen-config can not be combined with any other arguments.'
      end
    end

    def inspect_file(file)
      begin
        processed_source = SourceParser.parse_file(file)
      rescue Encoding::UndefinedConversionError, ArgumentError => e
        handle_error(e, "An error occurred while parsing #{file}.".color(:red))
        return []
      end

      # If we got any syntax errors, return only the syntax offences.
      # Parser may return nil for AST even though there are no syntax errors.
      # e.g. sources which contain only comments
      unless processed_source.diagnostics.empty?
        return processed_source.diagnostics.map do |diagnostic|
                 Cop::Offence.from_diagnostic(diagnostic)
               end
      end

      config = @config_store.for(file)
      if @options[:auto_gen_config] && config.contains_auto_generated_config
        fail "Remove #{Config::AUTO_GENERATED_FILE} from the current " +
          'configuration before generating it again.'
      end
      set_config_for_all_cops(config)

      cops = []
      @cops.each do |cop_class|
        cop_name = cop_class.cop_name
        next unless config.cop_enabled?(cop_name)
        next unless !@options[:only] || @options[:only] == cop_name
        cop = setup_cop(cop_class, processed_source.disabled_lines_for_cops)
        cops << cop
      end
      commissioner = Cop::Commissioner.new(cops)
      offences = commissioner.investigate(processed_source)
      process_commissioner_errors(file, commissioner.errors)
      autocorrect(processed_source.buffer, cops)
      offences.sort
    end

    def process_commissioner_errors(file, file_errors)
      file_errors.each do |cop, errors|
        errors.each do |e|
          handle_error(e,
                       "An error occurred while #{cop.name}".color(:red) +
                       " cop was inspecting #{file}.".color(:red))
        end
      end
    end

    def set_config_for_all_cops(config)
      @cops.each do |cop_class|
        cop_class.config = config.for_cop(cop_class.cop_name)
      end
    end

    def setup_cop(cop_class, disabled_lines_for_cops = nil)
      cop = cop_class.new
      cop.debug = @options[:debug]
      cop.autocorrect = @options[:autocorrect]
      if disabled_lines_for_cops
        cop.disabled_lines = disabled_lines_for_cops[cop_class.cop_name]
      end
      cop
    end

    def handle_error(e, message)
      @errors << message
      warn message
      if @options[:debug]
        puts e.message, e.backtrace
      else
        warn 'To see the complete backtrace run rubocop -d.'
      end
    end

    # rubocop:disable MethodLength
    def parse_options(args)
      convert_deprecated_options!(args)

      OptionParser.new do |opts|
        opts.banner = 'Usage: rubocop [options] [file1, file2, ...]'

        opts.on('-d', '--debug', 'Display debug info.') do |d|
          @options[:debug] = d
        end
        opts.on('-c', '--config FILE', 'Specify configuration file.') do |f|
          @options[:config] = f
          @config_store.set_options_config(@options[:config])
        end
        opts.on('--only COP', 'Run just one cop.') do |s|
          @options[:only] = s
          validate_only_option
        end
        opts.on('--auto-gen-config',
                'Generate a configuration file acting as a',
                'TODO list.') do
          @options[:auto_gen_config] = true
          @options[:formatters] = [
            [DEFAULT_FORMATTER],
            [Formatter::DisabledConfigFormatter, Config::AUTO_GENERATED_FILE]
          ]
          validate_auto_gen_config_option(args)
        end
        opts.on('-f', '--format FORMATTER',
                'Choose an output formatter. This option',
                'can be specified multiple times to enable',
                'multiple formatters at the same time.',
                '  [p]rogress (default)',
                '  [s]imple',
                '  [c]lang',
                '  [e]macs',
                '  [j]son',
                '  [f]iles',
                '  custom formatter class name') do |key|
          @options[:formatters] ||= []
          @options[:formatters] << [key]
        end
        opts.on('-o', '--out FILE',
                'Write output to a file instead of STDOUT.',
                'This option applies to the previously',
                'specified --format, or the default format',
                'if no format is specified.') do |path|
          @options[:formatters] ||= [[DEFAULT_FORMATTER]]
          @options[:formatters].last << path
        end
        opts.on('-r', '--require FILE', 'Require Ruby file.') do |f|
          require f
        end
        opts.on('-R', '--rails', 'Run extra Rails cops.') do |r|
          @options[:rails] = r
        end
        opts.on('-l', '--lint', 'Run only lint cops.') do |l|
          @options[:lint] = l
        end
        opts.on('-a', '--auto-correct', 'Auto-correct offences.') do |a|
          @options[:autocorrect] = a
        end
        opts.on('-s', '--silent', 'Silence summary.') do |s|
          @options[:silent] = s
        end
        opts.on('-n', '--no-color', 'Disable color output.') do |s|
          Sickill::Rainbow.enabled = false
        end
        opts.on('-v', '--version', 'Display version.') do
          puts Rubocop::Version.version(false)
          exit(0)
        end
        opts.on('-V', '--verbose-version', 'Display verbose version.') do
          puts Rubocop::Version.version(true)
          exit(0)
        end
      end.parse!(args)
    end
    # rubocop:enable MethodLength

    def convert_deprecated_options!(args)
      args.map! do |arg|
        case arg
        when '-e', '--emacs'
          deprecate("#{arg} option", '--format emacs', '1.0.0')
          %w(--format emacs)
        else
          arg
        end
      end.flatten!
    end

    def trap_interrupt
      Signal.trap('INT') do
        exit!(1) if wants_to_quit?
        self.wants_to_quit = true
        $stderr.puts
        $stderr.puts 'Exiting... Interrupt again to exit immediately.'
      end
    end

    def display_error_summary(errors)
      return if errors.empty?
      plural = errors.count > 1 ? 's' : ''
      puts "\n#{errors.count} error#{plural} occurred:".color(:red)
      errors.each { |error| puts error }
      puts 'Errors are usually caused by RuboCop bugs.'
      puts 'Please, report your problems to RuboCop\'s issue tracker.'
      puts 'Mention the following information in the issue report:'
      puts Rubocop::Version.version(true)
    end

    def autocorrect(buffer, cops)
      return unless @options[:autocorrect]

      corrections = cops.reduce([]) do |array, cop|
        array.concat(cop.corrections)
        array
      end

      corrector = Cop::Corrector.new(buffer, corrections)
      new_source = corrector.rewrite

      unless new_source == buffer.source
        filename = buffer.instance_variable_get(:@name)
        File.open(filename, 'w') { |f| f.write(new_source) }
      end
    end

    private

    def target_finder
      @target_finder ||= TargetFinder.new(@config_store, @options[:debug])
    end

    def formatter_set
      @formatter_set ||= begin
        set = Formatter::FormatterSet.new(!@options[:silent])
        pairs = @options[:formatters] || [[DEFAULT_FORMATTER]]
        pairs.each do |formatter_key, output_path|
          set.add_formatter(formatter_key, output_path)
        end
        set
      rescue => error
        warn error.message
        exit(1)
      end
    end

    def deprecate(subject, alternative = nil, version = nil)
      message =  "#{subject} is deprecated"
      message << " and will be removed in RuboCop #{version}" if version
      message << '.'
      message << " Please use #{alternative} instead." if alternative
      warn message
    end
  end
end
