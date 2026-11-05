# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantInterpolation, :config do
  it 'registers an offense for "#{1 + 1}"' do
    expect_offense(<<~'RUBY')
      "#{1 + 1}"
      ^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (1 + 1).to_s
    RUBY
  end

  it 'registers an offense for "%|#{1 + 1}|"' do
    expect_offense(<<~'RUBY')
      %|#{1 + 1}|
      ^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (1 + 1).to_s
    RUBY
  end

  it 'registers an offense for "%Q(#{1 + 1})"' do
    expect_offense(<<~'RUBY')
      %Q(#{1 + 1})
      ^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (1 + 1).to_s
    RUBY
  end

  it 'registers an offense for "#{1 + 1; 2 + 2}"' do
    expect_offense(<<~'RUBY')
      "#{1 + 1; 2 + 2}"
      ^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (1 + 1; 2 + 2).to_s
    RUBY
  end

  it 'registers an offense for "#{@var}"' do
    expect_offense(<<~'RUBY')
      "#{@var}"
      ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      @var.to_s
    RUBY
  end

  it 'registers an offense for "#@var"' do
    expect_offense(<<~'RUBY')
      "#@var"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      @var.to_s
    RUBY
  end

  it 'registers an offense for "#{@@var}"' do
    expect_offense(<<~'RUBY')
      "#{@@var}"
      ^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      @@var.to_s
    RUBY
  end

  it 'registers an offense for "#@@var"' do
    expect_offense(<<~'RUBY')
      "#@@var"
      ^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      @@var.to_s
    RUBY
  end

  it 'registers an offense for "#{$var}"' do
    expect_offense(<<~'RUBY')
      "#{$var}"
      ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $var.to_s
    RUBY
  end

  it 'registers an offense for "#$var"' do
    expect_offense(<<~'RUBY')
      "#$var"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $var.to_s
    RUBY
  end

  it 'registers an offense for "#{$1}"' do
    expect_offense(<<~'RUBY')
      "#{$1}"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $1.to_s
    RUBY
  end

  it 'registers an offense for "#$1"' do
    expect_offense(<<~'RUBY')
      "#$1"
      ^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $1.to_s
    RUBY
  end

  it 'registers an offense for "#{$+}"' do
    expect_offense(<<~'RUBY')
      "#{$+}"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $+.to_s
    RUBY
  end

  it 'registers an offense for "#$+"' do
    expect_offense(<<~'RUBY')
      "#$+"
      ^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $+.to_s
    RUBY
  end

  it 'registers an offense for "#{number}"' do
    expect_offense(<<~'RUBY')
      "#{number}"
      ^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      number.to_s
    RUBY
  end

  it 'registers an offense for "#{do_something(42)}"' do
    expect_offense(<<~'RUBY')
      "#{do_something(42)}"
      ^^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      do_something(42).to_s
    RUBY
  end

  it 'registers an offense for "#{do_something 42}"' do
    expect_offense(<<~'RUBY')
      "#{do_something 42}"
      ^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      do_something(42).to_s
    RUBY
  end

  it 'registers an offense for "#{foo.do_something 42}"' do
    expect_offense(<<~'RUBY')
      "#{foo.do_something 42}"
      ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      foo.do_something(42).to_s
    RUBY
  end

  it 'registers an offense for "#{var}"' do
    expect_offense(<<~'RUBY')
      var = 1; "#{var}"
               ^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      var = 1; var.to_s
    RUBY
  end

  it 'registers an offense for ["#{@var}"]' do
    expect_offense(<<~'RUBY')
      ["#{@var}", 'foo']
       ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      [@var.to_s, 'foo']
    RUBY
  end

  it 'registers an offense for a one-line `in` pattern matching', :ruby27 do
    # `42 in var` is `match-pattern` node.
    expect_offense(<<~'RUBY')
      "#{42 in var}"
      ^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (42 in var).to_s
    RUBY
  end

  it 'registers an offense for a one-line `in` pattern matching', :ruby30 do
    # `42 in var` is `match-pattern-p` node.
    expect_offense(<<~'RUBY')
      "#{42 in var}"
      ^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (42 in var).to_s
    RUBY
  end

  it 'accepts an offense for a one-line `=>` pattern matching', :ruby30 do
    # `42 => var` is `match-pattern` node.
    expect_no_offenses(<<~'RUBY')
      "#{42 => var}"
    RUBY
  end

  it 'accepts an offense for a part of one-line `=>` pattern matching', :ruby30 do
    # `42 => var` is `match-pattern` node.
    expect_no_offenses(<<~'RUBY')
      "#{x; 42 => var}"
    RUBY
  end

  it 'accepts an interpolated `return`' do
    expect_no_offenses(<<~'RUBY')
      "#{return foo}"
    RUBY
  end

  it 'accepts interpolated statements ending with `return`' do
    expect_no_offenses(<<~'RUBY')
      "#{foo; return}"
    RUBY
  end

  it 'accepts an interpolated `begin` whose body ends with `return`' do
    expect_no_offenses(<<~'RUBY')
      "#{begin
        return
      ensure
        foo
      end}"
    RUBY
  end

  it 'accepts an interpolated `begin` whose `ensure` ends with `return`' do
    expect_no_offenses(<<~'RUBY')
      "#{begin
        foo
      ensure
        return
      end}"
    RUBY
  end

  it 'accepts an interpolated `begin` whose body and `rescue` end with `return`' do
    expect_no_offenses(<<~'RUBY')
      "#{begin
        return
      rescue
        return
      end}"
    RUBY
  end

  it 'accepts an interpolated `begin` whose body and `else` end with `return`' do
    expect_no_offenses(<<~'RUBY')
      "#{begin
        return
      rescue
        foo
      else
        return
      end}"
    RUBY
  end

  it 'accepts an interpolated conditional whose branches all end with `return`' do
    expect_no_offenses(<<~'RUBY')
      "#{foo ? return : (return)}"
    RUBY
  end

  it 'accepts a parenthesized one-line `=>` pattern matching', :ruby30 do
    expect_no_offenses(<<~'RUBY')
      "#{(foo => bar)}"
    RUBY
  end

  it 'registers an offense for an interpolated `begin` whose `rescue` does not end with `return`' do
    expect_offense(<<~'RUBY')
      "#{begin
      ^^^^^^^^ Prefer `to_s` over string interpolation.
        return
      rescue
        foo
      end}"
    RUBY

    expect_correction(<<~RUBY)
      (begin
        return
      rescue
        foo
      end).to_s
    RUBY
  end

  it 'registers an offense for an interpolated `begin` whose body does not end with `return`' do
    expect_offense(<<~'RUBY')
      "#{begin
      ^^^^^^^^ Prefer `to_s` over string interpolation.
        foo
      rescue
        return
      end}"
    RUBY

    expect_correction(<<~RUBY)
      (begin
        foo
      rescue
        return
      end).to_s
    RUBY
  end

  it 'registers an offense for an interpolated `return` modifier' do
    expect_offense(<<~'RUBY')
      "#{return if foo}"
      ^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (return if foo).to_s
    RUBY
  end

  it 'accepts strings with characters before the interpolation' do
    expect_no_offenses('"this is #{@sparta}"')
  end

  it 'accepts strings with characters after the interpolation' do
    expect_no_offenses('"#{@sparta} this is"')
  end

  it 'accepts strings implicitly concatenated with a later string' do
    expect_no_offenses(%q("#{sparta}" ' this is'))
  end

  it 'accepts strings implicitly concatenated with an earlier string' do
    expect_no_offenses(%q('this is ' "#{sparta}"))
  end

  it 'accepts strings that are part of a %W()' do
    expect_no_offenses('%W(#{@var} foo)')
  end
end
