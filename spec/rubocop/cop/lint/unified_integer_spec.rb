# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnifiedInteger do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  shared_examples 'registers an offence' do |klass|
    context "when #{klass}" do
      context 'without any decorations' do
        let(:source) { "1.is_a?(#{klass})" }

        it 'registers an offence' do
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
          expect(cop.messages).to eq(["Use `Integer` instead of `#{klass}`."])
        end

        it 'autocorrects' do
          new_source = autocorrect_source(source)
          expect(new_source).to eq('1.is_a?(Integer)')
        end
      end

      context 'when explicitly specified as toplevel constant' do
        let(:source) { "1.is_a?(::#{klass})" }

        it 'registers an offence' do
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
          expect(cop.messages).to eq(["Use `Integer` instead of `#{klass}`."])
        end

        it 'autocorrects' do
          new_source = autocorrect_source(source)
          expect(new_source).to eq('1.is_a?(::Integer)')
        end
      end

      context 'with MyNamespace' do
        let(:source) { "1.is_a?(MyNamespace::#{klass})" }

        include_examples 'accepts'
      end
    end
  end

  include_examples 'registers an offence', 'Fixnum'
  include_examples 'registers an offence', 'Bignum'

  context 'when Integer' do
    context 'without any decorations' do
      it 'does not reguster an offense' do
        expect_no_offenses('1.is_a?(Integer)')
      end
    end

    context 'when explicitly specified as toplevel constant' do
      it 'does not reguster an offense' do
        expect_no_offenses('1.is_a?(::Integer)')
      end
    end

    context 'with MyNamespace' do
      it 'does not reguster an offense' do
        expect_no_offenses('1.is_a?(MyNamespace::Integer)')
      end
    end
  end
end
