# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DoubleNegation do
  subject(:cop) { described_class.new }

  it 'registers an offense for !!' do
    expect_offense(<<~RUBY)
      !!test.something
      ^ Avoid the use of double negation (`!!`).
    RUBY
  end

  it 'does not register an offense for !' do
    expect_no_offenses('!test.something')
  end

  it 'does not register an offense for not not' do
    expect_no_offenses('not not test.something')
  end
end
