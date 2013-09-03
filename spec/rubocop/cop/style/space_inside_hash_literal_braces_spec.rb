# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SpaceInsideHashLiteralBraces, :config do
        subject(:sihlb) { SpaceInsideHashLiteralBraces.new(config) }
        let(:cop_config) { { 'EnforcedStyleIsWithSpaces' => true } }

        it 'registers an offence for hashes with no spaces by default' do
          inspect_source(sihlb,
                         ['h = {a: 1, b: :two}',
                          'h = {a => 1 }'])
          expect(sihlb.messages).to eq(
            ['Space inside hash literal braces missing.'] * 3)
        end

        it 'registers an offence for hashes with no spaces if so configured' do
          inspect_source(sihlb,
                         ['h = {a: 1, b: 2}',
                          'h = {a => 1 }'])
          expect(sihlb.messages).to eq(
            ['Space inside hash literal braces missing.'] * 3)
        end

        context 'when EnforcedStyleIsWithSpaces is disabled' do
          let(:cop_config) { { 'EnforcedStyleIsWithSpaces' => false } }

          it 'registers an offence for hashes with spaces' do
            inspect_source(sihlb,
                           ['h = { a: 1, b: 2 }'])
            expect(sihlb.messages).to eq(
              ['Space inside hash literal braces detected.'] * 2)
          end

          it 'accepts hashes with no spaces' do
            inspect_source(sihlb,
                           ['h = {a: 1, b: 2}',
                            'h = {a => 1}'])
            expect(sihlb.messages).to be_empty
          end

          it 'accepts multiline hashes for no space' do
            inspect_source(sihlb,
                           ['h = {',
                            '      a: 1,',
                            '      b: 2,',
                            '}'])
            expect(sihlb.offences).to be_empty
          end

          it 'accepts empty hashes without spaces' do
            inspect_source(sihlb, ['h = {}'])
            expect(sihlb.offences).to be_empty
          end
        end

        it 'accepts hashes with spaces by default' do
          inspect_source(sihlb,
                         ['h = { a: 1, b: 2 }',
                          'h = { a => 1 }'])
          expect(sihlb.messages).to be_empty
        end

        it 'accepts empty hashes without spaces by default' do
          inspect_source(sihlb, ['h = {}'])
          expect(sihlb.offences).to be_empty
        end

        it 'accepts empty hashes without spaces even if configured true' do
          inspect_source(sihlb, ['h = {}'])
          expect(sihlb.offences).to be_empty
        end

        it 'accepts hash literals with no braces' do
          inspect_source(sihlb, ['x(a: b.c)'])
          expect(sihlb.offences).to be_empty
        end

        it 'can handle interpolation in a braceless hash literal' do
          # A tricky special case where the closing brace of the
          # interpolation risks getting confused for a hash literal brace.
          inspect_source(sihlb, ['f(get: "#{x}")'])
          expect(sihlb.offences).to be_empty
        end
      end
    end
  end
end
