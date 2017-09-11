# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Generator do
  subject(:generator)  { described_class.new(cop_identifier) }
  let(:cop_identifier) { 'Style/FakeCop' }

  before do
    allow(File).to receive(:write)
  end

  describe '#write_source' do
    it 'generates a helpful source file with the name filled in' do
      generated_source = <<-RUBY.strip_indent
        # frozen_string_literal: true

        # TODO: when finished, run `rake generate_cops_documentation` to update the docs
        module RuboCop
          module Cop
            module Style
              # TODO: Write cop description and example of bad / good code.
              #
              # @example
              #   # bad
              #   bad_method()
              #
              #   # bad
              #   bad_method(args)
              #
              #   # good
              #   good_method()
              #
              #   # good
              #   good_method(args)
              class FakeCop < Cop
                # TODO: Implement the cop into here.
                #
                # In many cases, you can use a node matcher for matching node pattern.
                # See. https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb
                #
                # For example
                MSG = 'Message of FakeCop'.freeze

                def_node_matcher :bad_method?, <<-PATTERN
                  (send nil :bad_method ...)
                PATTERN

                def on_send(node)
                  return unless bad_method?(node)
                  add_offense(node)
                end
              end
            end
          end
        end
      RUBY

      generator.write_source

      expect(File)
        .to have_received(:write)
        .with('lib/rubocop/cop/style/fake_cop.rb', generated_source)
    end

    it 'refuses to overwrite existing files' do
      new_cop = described_class.new('Layout/Tab')

      expect { new_cop.write_source }
        .to raise_error('lib/rubocop/cop/layout/tab.rb already exists!')
    end
  end

  describe '#write_spec' do
    it 'generates a helpful starting spec file with the class filled in' do
      generated_source = <<-SPEC.strip_indent
        # frozen_string_literal: true

        describe RuboCop::Cop::Style::FakeCop do
          let(:config) { RuboCop::Config.new }
          subject(:cop) { described_class.new(config) }

          # TODO: Write test code
          #
          # For example
          it 'registers an offense when using `#bad_method`' do
            expect_offense(<<-RUBY.strip_indent)
              bad_method
              ^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
            RUBY
          end

          it 'does not register an offense when using `#good_method`' do
            expect_no_offenses(<<-RUBY.strip_indent)
              good_method
            RUBY
          end
        end
      SPEC

      generator.write_spec

      expect(File)
        .to have_received(:write)
        .with('spec/rubocop/cop/style/fake_cop_spec.rb', generated_source)
    end

    it 'refuses to overwrite existing files' do
      new_cop = described_class.new('Layout/Tab')

      expect { new_cop.write_spec }
        .to raise_error('spec/rubocop/cop/layout/tab_spec.rb already exists!')
    end
  end

  describe '#todo' do
    it 'provides a checklist for implementing the cop' do
      expect(generator.todo).to eql(<<-TODO.strip_indent)
        Files created:
          - lib/rubocop/cop/style/fake_cop.rb
          - spec/rubocop/cop/style/fake_cop_spec.rb

        Do 3 steps:
          1. Add an entry to the "New features" section in CHANGELOG.md,
             e.g. "Add new `FakeCop` cop. ([@your_id][])"
          2. Add an entry into config/enabled.yml or config/disabled.yml
          3. Implement your new cop in the generated file!
      TODO
    end
  end

  describe '.new' do
    it 'does not accept an unqualified cop' do
      expect { described_class.new('FakeCop') }
        .to raise_error(ArgumentError)
        .with_message('Specify a cop name with Department/Name style')
    end
  end

  describe '#inject_require' do
    context 'when a `require` entry does not exist from before' do
      before do
        allow(File)
          .to receive(:readlines).with('lib/rubocop.rb')
                                 .and_return(<<-RUBY.strip_indent.lines)
          # frozen_string_literal: true

          require 'parser'
          require 'rainbow'

          require 'English'
          require 'set'
          require 'forwardable'

          require 'rubocop/version'

          require 'rubocop/cop/style/end_block'
          require 'rubocop/cop/style/even_odd'
          require 'rubocop/cop/style/file_name'
          require 'rubocop/cop/style/flip_flop'

          require 'rubocop/cop/rails/action_filter'

          require 'rubocop/cop/team'
        RUBY
      end

      it 'injects a `require` statement on the right line in the root file' do
        generated_source = <<-RUBY.strip_indent
          # frozen_string_literal: true

          require 'parser'
          require 'rainbow'

          require 'English'
          require 'set'
          require 'forwardable'

          require 'rubocop/version'

          require 'rubocop/cop/style/end_block'
          require 'rubocop/cop/style/even_odd'
          require 'rubocop/cop/style/fake_cop'
          require 'rubocop/cop/style/file_name'
          require 'rubocop/cop/style/flip_flop'

          require 'rubocop/cop/rails/action_filter'

          require 'rubocop/cop/team'
        RUBY

        generator.inject_require

        expect(File)
          .to have_received(:write).with('lib/rubocop.rb', generated_source)
      end
    end

    context 'when a cop of style department already exists' do
      let(:cop_identifier) { 'Style/TheEndOfStyle' }

      before do
        allow(File)
          .to receive(:readlines).with('lib/rubocop.rb')
                                 .and_return(<<-RUBY.strip_indent.lines)
          # frozen_string_literal: true

          require 'parser'
          require 'rainbow'

          require 'English'
          require 'set'
          require 'forwardable'

          require 'rubocop/version'

          require 'rubocop/cop/style/end_block'
          require 'rubocop/cop/style/even_odd'
          require 'rubocop/cop/style/file_name'
          require 'rubocop/cop/style/flip_flop'

          require 'rubocop/cop/rails/action_filter'

          require 'rubocop/cop/team'
        RUBY
      end

      it 'injects a `require` statement on the end of style department' do
        generated_source = <<-RUBY.strip_indent
          # frozen_string_literal: true

          require 'parser'
          require 'rainbow'

          require 'English'
          require 'set'
          require 'forwardable'

          require 'rubocop/version'

          require 'rubocop/cop/style/end_block'
          require 'rubocop/cop/style/even_odd'
          require 'rubocop/cop/style/file_name'
          require 'rubocop/cop/style/flip_flop'
          require 'rubocop/cop/style/the_end_of_style'

          require 'rubocop/cop/rails/action_filter'

          require 'rubocop/cop/team'
        RUBY

        generator.inject_require
        expect(File)
          .to have_received(:write).with('lib/rubocop.rb', generated_source)
      end
    end

    context 'when a `require` entry already exists' do
      before do
        allow(File)
          .to receive(:readlines).with('lib/rubocop.rb')
                                 .and_return(<<-RUBY.strip_indent.lines)
          # frozen_string_literal: true

          require 'parser'
          require 'rainbow'

          require 'English'
          require 'set'
          require 'forwardable'

          require 'rubocop/version'

          require 'rubocop/cop/style/end_block'
          require 'rubocop/cop/style/even_odd'
          require 'rubocop/cop/style/fake_cop'
          require 'rubocop/cop/style/file_name'
          require 'rubocop/cop/style/flip_flop'

          require 'rubocop/cop/rails/action_filter'

          require 'rubocop/cop/team'
        RUBY
      end

      it 'does not write to any file' do
        generator.inject_require

        expect(File).not_to have_received(:write)
      end
    end

    context 'when using an unknown department' do
      let(:cop_identifier) { 'Unknown/FakeCop' }

      before do
        allow(File)
          .to receive(:readlines).with('lib/rubocop.rb')
                                 .and_return(<<-RUBY.strip_indent.lines)
          # frozen_string_literal: true

          require 'parser'
          require 'rainbow'

          require 'English'
          require 'set'
          require 'forwardable'

          require 'rubocop/version'

          require 'rubocop/cop/style/end_block'
          require 'rubocop/cop/style/even_odd'
          require 'rubocop/cop/style/fake_cop'
          require 'rubocop/cop/style/file_name'
          require 'rubocop/cop/style/flip_flop'

          require 'rubocop/cop/rails/action_filter'

          require 'rubocop/cop/team'
        RUBY
      end

      it 'does not write to any file' do
        generator.inject_require

        expect(File).not_to have_received(:write)
      end
    end
  end
end
