# encoding: utf-8
# rubocop:disable LineLength

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe EndAlignment do
        let(:cop) { EndAlignment.new }

        it 'registers an offence for mismatched class end' do
          inspect_source(cop,
                         ['class Test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched module end' do
          inspect_source(cop,
                         ['module Test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched def end' do
          inspect_source(cop,
                         ['def test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched defs end' do
          inspect_source(cop,
                         ['def Test.test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched if end' do
          inspect_source(cop,
                         ['if test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched while end' do
          inspect_source(cop,
                         ['while test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched until end' do
          inspect_source(cop,
                         ['until test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end
      end
    end
  end
end
