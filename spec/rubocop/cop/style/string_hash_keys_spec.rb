# frozen_string_literal: true

describe RuboCop::Cop::Style::StringHashKeys do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using strings as keys' do
    expect_offense(<<-RUBY.strip_indent)
      { 'one' => 1 }
        ^^^^^ Prefer symbols instead of strings as hash keys.
    RUBY
  end

  it 'registers an offense when using strings as keys mixed with other keys' do
    expect_offense(<<-RUBY.strip_indent)
      { 'one' => 1, two: 2, 3 => 3 }
        ^^^^^ Prefer symbols instead of strings as hash keys.
    RUBY
  end

  it 'autocorrects strings as keys into symbols' do
    new_source = autocorrect_source("{ 'one' => 1 }")
    expect(new_source).to eq '{ :one => 1 }'
  end

  it 'autocorrects strings as keys mixed with other keys into symbols' do
    new_source = autocorrect_source("{ 'one' => 1, two: 2, 3 => 3 }")
    expect(new_source).to eq '{ :one => 1, two: 2, 3 => 3 }'
  end

  it 'autocorrects strings as keys into symbols with the correct syntax' do
    new_source = autocorrect_source("{ 'one two :' => 1 }")
    expect(new_source).to eq '{ :"one two :" => 1 }'
  end

  it 'does not register an offense when not using strings as keys' do
    expect_no_offenses(<<-RUBY.strip_indent)
      { one: 1 }
    RUBY
  end
end
