# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EndBlock do
  subject(:cop) { described_class.new }

  it 'reports an offense for an END block' do
    src = 'END { test }'
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end
end
