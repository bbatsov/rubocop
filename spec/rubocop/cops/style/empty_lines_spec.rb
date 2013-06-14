# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe EmptyLines do
        let(:empty_lines) { EmptyLines.new }

        it 'registers an offence for consecutive empty lines' do
          inspect_source(empty_lines,
                         ['test = 5', '', '', '', 'top'])
          expect(empty_lines.offences.size).to eq(2)
        end

        it 'works when there are no tokens' do
          inspect_source(empty_lines,
                         ['#comment'])
          expect(empty_lines.offences).to be_empty
        end

        it 'handles comments' do
          inspect_source(empty_lines,
                         ['test', '', '#comment', 'top'])
          expect(empty_lines.offences).to be_empty
        end

        it 'does not register an offence for empty lines in a string' do
          inspect_source(empty_lines, ['result = "test



                                        string"'])
          expect(empty_lines.offences).to be_empty
        end
      end
    end
  end
end
