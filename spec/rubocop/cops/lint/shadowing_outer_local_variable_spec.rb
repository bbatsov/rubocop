# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe ShadowingOuterLocalVariable do
        subject(:cop) { ShadowingOuterLocalVariable.new }

        context 'when a block argument has same name ' +
                'as an outer scope variable' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  puts foo',
              '  1.times do |foo|',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('Shadowing outer local variable - foo')
            expect(cop.offences.first.line).to eq(4)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a splat block argument has same name ' +
                'as an outer scope variable' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  puts foo',
              '  1.times do |*foo|',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('Shadowing outer local variable - foo')
            expect(cop.offences.first.line).to eq(4)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a block block argument has same name ' +
                'as an outer scope variable' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  puts foo',
              '  proc_taking_block = proc do |&foo|',
              '  end',
              '  proc_taking_block.call do',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('Shadowing outer local variable - foo')
            expect(cop.offences.first.line).to eq(4)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a block local variable has same name ' +
                'as an outer scope variable' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  puts foo',
              '  1.times do |i; foo|',
              '    puts foo',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('Shadowing outer local variable - foo')
            expect(cop.offences.first.line).to eq(4)
          end

          include_examples 'mimics MRI 2.0', 'shadowing'
        end

        context 'when a block argument has different name ' +
                'with outer scope variables' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  puts foo',
              '  1.times do |bar|',
              '  end',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when an outer scope variable is reassigned in a block' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  puts foo',
              '  1.times do',
              '    foo = 2',
              '  end',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when an outer scope variable is referenced in a block' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  puts foo',
              '  1.times do',
              '    puts foo',
              '  end',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a method argument has same name ' +
                'as an outer scope variable' do
          let(:source) do
            [
              'class SomeClass',
              '  foo = 1',
              '  puts foo',
              '  def some_method(foo)',
              '  end',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end
      end
    end
  end
end
