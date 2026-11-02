# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SendWithMixinArgument, :config do
  it 'registers an offense when using `send` with `include`' do
    expect_offense(<<~RUBY)
      Foo.send(:include, Bar)
          ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.include Bar
    RUBY
  end

  it 'registers an offense when using `send` with `include` and no explicit receiver' do
    expect_offense(<<~RUBY)
      class Foo
        send(:include, Bar)
        ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        include Bar
      end
    RUBY
  end

  it 'registers an offense when using `send` with `include` and a `self` receiver' do
    expect_offense(<<~RUBY)
      class Foo
        self.send(:include, Bar)
             ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        self.include Bar
      end
    RUBY
  end

  it 'registers an offense when using `send` with `prepend`' do
    expect_offense(<<~RUBY)
      Foo.send(:prepend, Bar)
          ^^^^^^^^^^^^^^^^^^^ Use `prepend Bar` instead of `send(:prepend, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.prepend Bar
    RUBY
  end

  it 'registers an offense when using `send` with `extend`' do
    expect_offense(<<~RUBY)
      Foo.send(:extend, Bar)
          ^^^^^^^^^^^^^^^^^^ Use `extend Bar` instead of `send(:extend, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.extend Bar
    RUBY
  end

  it 'registers an offense and corrects with parentheses when the return value is used' do
    expect_offense(<<~RUBY)
      [Foo.send(:extend, Bar)]
           ^^^^^^^^^^^^^^^^^^ Use `extend Bar` instead of `send(:extend, Bar)`.
      baz(Foo.send(:include, Bar, Qux), 1)
              ^^^^^^^^^^^^^^^^^^^^^^^^ Use `include Bar, Qux` instead of `send(:include, Bar, Qux)`.
    RUBY

    expect_correction(<<~RUBY)
      [Foo.extend(Bar)]
      baz(Foo.include(Bar, Qux), 1)
    RUBY
  end

  it 'registers an offense and corrects with parentheses in a ternary branch' do
    expect_offense(<<~RUBY)
      x = cond ? Foo.send(:include, Bar) : nil
                     ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      x = cond ? Foo.include(Bar) : nil
    RUBY
  end

  it 'registers an offense and corrects with parentheses when a method is chained' do
    expect_offense(<<~RUBY)
      Foo.send(:include, Bar).tap {}
          ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.include(Bar).tap {}
    RUBY
  end

  it 'registers an offense and corrects with parentheses when a block is given' do
    expect_offense(<<~RUBY)
      Foo.send(:include, Bar) {}
          ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.include(Bar) {}
    RUBY
  end

  it 'registers an offense and corrects without parentheses in a modifier `if`' do
    expect_offense(<<~RUBY)
      Foo.send(:include, Bar) if cond
          ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.include Bar if cond
    RUBY
  end

  it 'registers an offense and corrects with parentheses in an `if` condition' do
    expect_offense(<<~RUBY)
      bar if Foo.send(:include, Bar)
                 ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      bar if Foo.include(Bar)
    RUBY
  end

  it 'registers an offense and corrects with parentheses in an endless method body', :ruby30 do
    expect_offense(<<~RUBY)
      private def e = Foo.send(:include, Bar)
                          ^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      private def e = Foo.include(Bar)
    RUBY
  end

  context 'when specifying a mixin method as a string' do
    it 'registers an offense when using `send` with `include`' do
      expect_offense(<<~RUBY)
        Foo.send('include', Bar)
            ^^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `send('include', Bar)`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.include Bar
      RUBY
    end

    it 'registers an offense when using `send` with `prepend`' do
      expect_offense(<<~RUBY)
        Foo.send('prepend', Bar)
            ^^^^^^^^^^^^^^^^^^^^ Use `prepend Bar` instead of `send('prepend', Bar)`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.prepend Bar
      RUBY
    end

    it 'registers an offense when using `send` with `extend`' do
      expect_offense(<<~RUBY)
        Foo.send('extend', Bar)
            ^^^^^^^^^^^^^^^^^^^ Use `extend Bar` instead of `send('extend', Bar)`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.extend Bar
      RUBY
    end
  end

  it 'registers an offense when using `public_send` method' do
    expect_offense(<<~RUBY)
      Foo.public_send(:include, Bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `public_send(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.include Bar
    RUBY
  end

  it 'registers an offense when using `public_send` with `prepend`' do
    expect_offense(<<~RUBY)
      Foo.public_send(:prepend, Bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `prepend Bar` instead of `public_send(:prepend, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.prepend Bar
    RUBY
  end

  it 'registers an offense when using `__send__` with `extend`' do
    expect_offense(<<~RUBY)
      Foo.__send__(:extend, Bar)
          ^^^^^^^^^^^^^^^^^^^^^^ Use `extend Bar` instead of `__send__(:extend, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.extend Bar
    RUBY
  end

  it 'registers an offense when using `__send__` method' do
    expect_offense(<<~RUBY)
      Foo.__send__(:include, Bar)
          ^^^^^^^^^^^^^^^^^^^^^^^ Use `include Bar` instead of `__send__(:include, Bar)`.
    RUBY

    expect_correction(<<~RUBY)
      Foo.include Bar
    RUBY
  end

  it 'does not register an offense when not using a mixin method' do
    expect_no_offenses(<<~RUBY)
      Foo.send(:do_something, Bar)
    RUBY
  end

  it 'does not register an offense when using `include`' do
    expect_no_offenses(<<~RUBY)
      Foo.include Bar
    RUBY
  end

  it 'does not register an offense when using `prepend`' do
    expect_no_offenses(<<~RUBY)
      Foo.prepend Bar
    RUBY
  end

  it 'does not register an offense when using `extend`' do
    expect_no_offenses(<<~RUBY)
      Foo.extend Bar
    RUBY
  end

  context 'when using namespace for module' do
    it 'registers an offense when using `send` with `include`' do
      expect_offense(<<~RUBY)
        A::Foo.send(:include, B::Bar)
               ^^^^^^^^^^^^^^^^^^^^^^ Use `include B::Bar` instead of `send(:include, B::Bar)`.
      RUBY

      expect_correction(<<~RUBY)
        A::Foo.include B::Bar
      RUBY
    end
  end

  context 'when multiple arguments are passed' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Foo.send(:include, Bar, Baz)
            ^^^^^^^^^^^^^^^^^^^^^^^^ Use `include Bar, Baz` instead of `send(:include, Bar, Baz)`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.include Bar, Baz
      RUBY
    end
  end
end
