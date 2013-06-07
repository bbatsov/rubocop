# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Formatter
    describe BaseFormatter do
      include FileHelper

      describe 'how the API methods are invoked', :isolated_environment do
        subject(:formatter) { double('formatter').as_null_object }
        let(:cli) { CLI.new }
        let(:output) { $stdout.string }

        before do
          create_file('1_offence.rb', [
            '# encoding: utf-8',
            '#' * 90
          ])

          create_file('4_offences.rb', [
            '# encoding: utf-8',
            'puts x ',
            'test;',
            'top;',
            '#' * 90
          ])

          create_file('no_offence.rb', [
            '# encoding: utf-8'
          ])

          SimpleTextFormatter.stub(:new).and_return(formatter)
          $stdout = StringIO.new
        end

        after do
          $stdout = STDOUT
        end

        def run
          cli.run([])
        end

        describe 'invocation order' do
          subject(:formatter) do
            formatter = double('formatter')
            def formatter.method_missing(method_name, *args)
              return if method_name == :output
              puts method_name
            end
            formatter
          end

          it 'is called in the proper sequence' do
            run
            expect(output).to eq([
              'started',
              'file_started',
              'file_finished',
              'file_started',
              'file_finished',
              'file_started',
              'file_finished',
              'finished',
              ''
            ].join("\n"))
          end
        end

        shared_examples 'receives all file paths' do |method_name|
          it 'receives all file paths' do
            expected_paths = [
              '1_offence.rb',
              '4_offences.rb',
              'no_offence.rb'
            ].map { |path| File.expand_path(path) }.sort

            formatter.should_receive(method_name) do |all_files|
              expect(all_files.sort).to eq(expected_paths)
            end

            run
          end
        end

        describe '#started' do
          include_examples 'receives all file paths', :started
        end

        describe '#finished' do
          context 'when RuboCop finished inspecting all files normally' do
            include_examples 'receives all file paths', :started
          end

          context 'when RuboCop is interrupted by user' do
            it 'received processed file paths' do
              class << formatter
                attr_reader :processed_file_count

                def file_finished(file, offences)
                  @processed_file_count ||= 0
                  @processed_file_count += 1
                end
              end

              cli.stub(:wants_to_quit?) do
                formatter.processed_file_count == 2
              end

              formatter.should_receive(:finished) do |processed_files|
                expect(processed_files).to have(2).items
              end

              run
            end
          end
        end

        shared_examples 'receives a file path' do |method_name|
          it 'receives a file path' do
            formatter.should_receive(method_name)
              .with(File.expand_path('1_offence.rb'), anything)

            formatter.should_receive(method_name)
              .with(File.expand_path('4_offences.rb'), anything)

            formatter.should_receive(method_name)
              .with(File.expand_path('no_offence.rb'), anything)

            run
          end
        end

        describe '#file_started' do
          include_examples 'receives a file path', :file_started

          it 'receives file specific information hash' do
            formatter.should_receive(:file_started)
              .with(anything, an_instance_of(Hash)).exactly(3).times
            run
          end
        end

        describe '#file_finished' do
          include_examples 'receives a file path', :file_finished

          it 'receives an array of detected offences for the file' do
            formatter.should_receive(:file_finished)
            .exactly(3).times do |file, offences|
              case File.basename(file)
              when '1_offence.rb'
                expect(offences).to have(1).item
              when '4_offences.rb'
                expect(offences).to have(4).items
              when 'no_offence.rb'
                expect(offences).to be_empty
              else
                fail
              end
              expect(offences.all? { |o| o.is_a?(Rubocop::Cop::Offence) })
                .to be_true
            end
            run
          end
        end
      end
    end
  end
end
