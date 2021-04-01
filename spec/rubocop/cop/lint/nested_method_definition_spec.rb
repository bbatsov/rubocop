# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NestedMethodDefinition, :config do
  it 'registers an offense for a nested method definition' do
    expect_offense(<<~RUBY)
      def x; def y; end; end
             ^^^^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
    RUBY
  end

  it 'registers an offense for a nested singleton method definition' do
    expect_offense(<<~RUBY)
      class Foo
      end
      foo = Foo.new
      def foo.bar
        def baz
        ^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
        end
      end
    RUBY
  end

  it 'registers an offense for a nested method definition inside lambda' do
    expect_offense(<<~RUBY)
      def foo
        bar = -> { def baz; puts; end }
                   ^^^^^^^^^^^^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
      end
    RUBY
  end

  it 'registers an offense for a nested class method definition' do
    expect_offense(<<~RUBY)
      class Foo
        def self.x
          def self.y
          ^^^^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
          end
        end
      end
    RUBY
  end

  it 'does not register an offense for a lambda definition inside method' do
    expect_no_offenses(<<~RUBY)
      def foo
        bar = -> { puts  }
        bar.call
      end
    RUBY
  end

  it 'does not register offense for nested definition inside instance_eval' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(obj)
          obj.instance_eval do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside instance_exec' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(obj)
          obj.instance_exec do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for definition of method on local var' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(obj)
          def obj.y
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside class_eval' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(klass)
          klass.class_eval do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside class_exec' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(klass)
          klass.class_exec do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside module_eval' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define(mod)
          mod.module_eval do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside module_exec' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define(mod)
          mod.module_exec do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside class shovel' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def bar
          class << self
            def baz
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside Class.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          Class.new(S) do
            def y
            end
          end
        end
      end

      class Foo
        def self.define
          Class.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside ::Class.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          ::Class.new(S) do
            def y
            end
          end
        end
      end

      class Foo
        def self.define
          ::Class.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside Module.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          Module.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside ::Module.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          ::Module.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside Struct.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          Struct.new(:name) do
            def y
            end
          end
        end
      end

      class Foo
        def self.define
          Struct.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside ::Struct.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          ::Struct.new(:name) do
            def y
            end
          end
        end
      end

      class Foo
        def self.define
          ::Struct.new do
            def y
            end
          end
        end
      end
    RUBY
  end
end
