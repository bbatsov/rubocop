# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SpaceAroundBlockBraces, :config do
        subject(:cop) { SpaceAroundBlockBraces.new(config) }
        let(:cop_config) { { 'NoSpaceBeforeBlockParameters' => false } }

        it 'accepts braces surrounded by spaces' do
          inspect_source(cop, ['each { puts }'])
          expect(cop.messages).to be_empty
          expect(cop.highlights).to be_empty
        end

        it 'registers an offence for left brace without outer space' do
          inspect_source(cop, ['each{ puts }'])
          expect(cop.messages).to eq(["Surrounding space missing for '{'."])
          expect(cop.highlights).to eq(['{'])
        end

        it 'registers an offence for left brace without inner space' do
          inspect_source(cop, ['each {puts }'])
          expect(cop.messages).to eq(["Surrounding space missing for '{'."])
          expect(cop.highlights).to eq(['{'])
        end

        it 'registers an offence for right brace without inner space' do
          inspect_source(cop, ['each { puts}'])
          expect(cop.messages).to eq(["Space missing to the left of '}'."])
          expect(cop.highlights).to eq(['}'])
        end

        context 'with passed in parameters' do
          it 'accepts left brace with inner space' do
            inspect_source(cop, ['each { |x| puts }'])
            expect(cop.messages).to be_empty
            expect(cop.highlights).to be_empty
          end

          it 'registers an offence for left brace without inner space' do
            inspect_source(cop, ['each {|x| puts }'])
            expect(cop.messages).to eq(["Surrounding space missing for '{'."])
            expect(cop.highlights).to eq(['{'])
          end

          context 'space before block parameters not allowed' do
            let(:cop_config) { { 'NoSpaceBeforeBlockParameters' => true } }

            it 'registers an offence for left brace with inner space' do
              inspect_source(cop, ['each { |x| puts }'])
              expect(cop.messages).to eq(['Space between { and | detected.'])
              expect(cop.highlights).to eq(['{'])
            end

            it 'accepts left brace without inner space' do
              inspect_source(cop, ['each {|x| puts }'])
              expect(cop.messages).to be_empty
              expect(cop.highlights).to be_empty
            end
          end
        end
      end
    end
  end
end
