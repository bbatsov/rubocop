# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantArgument, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'Methods' => { 'join' => '', 'split' => ' ' } }
  end

  it 'registers an offense when method called on variable' do
    expect_offense(<<~RUBY)
      foo.join('')
      ^^^^^^^^^^^^ Argument '' is redundant because it is implied by default.
      foo.split(' ')
      ^^^^^^^^^^^^^^ Argument ' ' is redundant because it is implied by default.
    RUBY
  end

  it 'registers an offense when method called on literals' do
    expect_offense(<<~RUBY)
      [1, 2, 3].join('')
      ^^^^^^^^^^^^^^^^^^ Argument '' is redundant because it is implied by default.
      "first second".split(' ')
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Argument ' ' is redundant because it is implied by default.
    RUBY
  end

  it 'works with double-quoted strings when configuration is single-quotes' do
    expect_offense(<<~RUBY)
      foo.join("")
      ^^^^^^^^^^^^ Argument "" is redundant because it is implied by default.
      "first second".split(" ")
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Argument " " is redundant because it is implied by default.
    RUBY
  end

  it 'does not register an offense when method called with no arguments' do
    expect_no_offenses(<<~RUBY)
      foo.join
      "first second".split
    RUBY
  end

  it 'does not register an offense when method called with more than one arguments' do
    expect_no_offenses(<<~RUBY)
      foo.join('', 2)
      [1, 2, 3].split(" ", true, {})
    RUBY
  end

  it 'does not register an offense when method called with different argument' do
    expect_no_offenses(<<~RUBY)
      foo.join(',')
      foo.split(',')
    RUBY
  end

  it 'does not register an offense when method called with no receiver' do
    expect_no_offenses(<<~RUBY)
      join('')
      split(' ')
    RUBY
  end

  context 'non-builtin method' do
    let(:cop_config) do
      { 'Methods' => { 'foo' => 2 } }
    end

    it 'registers an offense with configured argument' do
      expect_offense(<<~RUBY)
        A.foo(2)
        ^^^^^^^^ Argument 2 is redundant because it is implied by default.
      RUBY
    end

    it 'does not register an offense with other argument' do
      expect_no_offenses(<<~RUBY)
        A.foo(5)
      RUBY
    end
  end
end
