# frozen_string_literal: true

describe RuboCop::Cop::Style::Not, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for not' do
    expect_offense(<<-RUBY.strip_indent)
      not test
      ^^^ Use `!` instead of `not`.
    RUBY
  end

  it 'does not register an offense for !' do
    expect_no_offenses('!test')
  end

  it 'auto-corrects "not" with !' do
    new_source = autocorrect_source(cop, 'x = 10 if not y')
    expect(new_source).to eq('x = 10 if !y')
  end

  it 'auto-corrects "not" followed by parens with !' do
    new_source = autocorrect_source(cop, 'not(test)')
    expect(new_source).to eq('!(test)')
  end

  it 'uses the reverse operator when `not` is applied to a comparison' do
    src = 'not x < y'
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq('x >= y')
  end

  it 'parenthesizes when `not` would change the meaning of a binary exp' do
    src = 'not a >> b'
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq('!(a >> b)')
  end

  it 'parenthesizes when `not` is applied to a ternary op' do
    src = 'not a ? b : c'
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq('!(a ? b : c)')
  end

  it 'parenthesizes when `not` is applied to and' do
    src = 'not a && b'
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq('!(a && b)')
  end

  it 'parenthesizes when `not` is applied to or' do
    src = 'not a || b'
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq('!(a || b)')
  end
end
