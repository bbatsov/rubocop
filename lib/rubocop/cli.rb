# encoding: utf-8

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    # If set true while running,
    # RuboCop will abort processing and exit gracefully.
    attr_accessor :wants_to_quit
    attr_reader :options

    alias_method :wants_to_quit?, :wants_to_quit

    def initialize
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

      @options, remaining_args = Options.new.parse(args)

      act_on_preemptive_options(remaining_args)

      target_files = target_finder.find(remaining_args)

      act_on_options(remaining_args)

      any_failed = process_files(target_files)

      display_error_summary(@errors)

      !any_failed && !wants_to_quit ? 0 : 1
    rescue => e
      $stderr.puts e.message
      return 1
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
      warn "\n#{errors.count} error#{plural} occurred:".color(:red)
      errors.each { |error| warn error }
      warn 'Errors are usually caused by RuboCop bugs.'
      warn 'Please, report your problems to RuboCop\'s issue tracker.'
      warn 'Mention the following information in the issue report:'
      warn Rubocop::Version.version(true)
    end

    private

    def process_files(target_files)
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
      any_failed
    end

    def act_on_preemptive_options(args)
      if @options[:show_cops]
        print_available_cops
        exit(0)
      end
      if @options[:version]
        puts Rubocop::Version.version(false)
        exit(0)
      end
      if @options[:verbose_version]
        puts Rubocop::Version.version(true)
        exit(0)
      end
    end

    def act_on_options(args)
      @config_store.set_options_config(@options[:config]) if @options[:config]

      Sickill::Rainbow.enabled = false if @options[:no_color]

      ConfigLoader.debug = @options[:debug]

      if @options[:auto_gen_config]
        target_finder.find(args).each do |file|
          config = @config_store.for(file)
          if config.contains_auto_generated_config
            fail "Remove #{ConfigLoader::AUTO_GENERATED_FILE} from the " +
              'current configuration before generating it again.'
          end
        end
      end
    end

    def mobilized_cop_classes(config)
      @mobilized_cop_classes ||= {}
      @mobilized_cop_classes[config.object_id] ||= begin
        cop_classes = Cop::Cop.all

        if @options[:only]
          cop_classes.select! { |c| c.cop_name == @options[:only] }
        else
          # filter out Rails cops unless requested
          cop_classes.reject!(&:rails?) unless run_rails_cops?(config)

          # filter out style cops when --lint is passed
          cop_classes.select!(&:lint?) if @options[:lint]
        end

        cop_classes
      end
    end

    def inspect_file(file)
      config = @config_store.for(file)
      team = Cop::Team.new(mobilized_cop_classes(config), config, @options)
      offences = team.inspect_file(file)
      @errors.concat(team.errors)
      offences
    end

    def print_available_cops
      cops = Cop::Cop.all
      puts "Available cops (#{cops.length}) + config for #{Dir.pwd.to_s}: "
      dirconf = @config_store.for(Dir.pwd.to_s)
      cops.types.sort!.each do |type|
        coptypes = cops.with_type(type).sort_by!(&:cop_name)
        puts "Type '#{type.to_s.capitalize}' (#{coptypes.size}):"
        coptypes.each do |cop|
          puts " - #{cop.cop_name}"
          cnf = dirconf.for_cop(cop).dup
          print_conf_option('Description',
                            cnf.delete('Description') { 'None' })
          cnf.each { |k, v| print_conf_option(k, v) }
          print_conf_option('SupportsAutoCorrection',
                            cop.new.support_autocorrect?.to_s)
        end
      end
    end

    def print_conf_option(option, value)
      puts  "    - #{option}: #{value}"
    end

    def target_finder
      @target_finder ||= TargetFinder.new(@config_store, @options[:debug])
    end

    def run_rails_cops?(config)
      @options[:rails] || config['AllCops']['RunRailsCops']
    end

    def formatter_set
      @formatter_set ||= begin
        set = Formatter::FormatterSet.new
        pairs = @options[:formatters] || [[Options::DEFAULT_FORMATTER]]
        pairs.each do |formatter_key, output_path|
          set.add_formatter(formatter_key, output_path)
        end
        set
      rescue => error
        warn error.message
        exit(1)
      end
    end
  end
end
