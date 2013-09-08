# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe VariableInspector do
      include AST::Sexp

      class ExampleInspector
        include VariableInspector
      end

      subject(:inspector) { ExampleInspector.new }

      describe '#process_node' do
        before do
          inspector.variable_table.push_scope(s(:def))
        end

        context 'when processing lvar node' do
          let(:node) { s(:lvar, :foo) }

          context 'when the variable is not yet declared' do
            it 'raises error' do
              expect { inspector.process_node(node) }.to raise_error
            end
          end
        end
      end
    end
  end
end
