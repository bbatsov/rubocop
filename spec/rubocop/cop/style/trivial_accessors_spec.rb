# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrivialAccessors, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { {} }

  it 'registers an offense on instance reader' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
      ^^^ Use `attr_reader` to define trivial reader methods.
        @foo
      end
    RUBY
  end

  it 'registers an offense on instance writer' do
    expect_offense(<<-RUBY.strip_indent)
      def foo=(val)
      ^^^ Use `attr_writer` to define trivial writer methods.
        @foo = val
      end
    RUBY
  end

  it 'registers an offense on class reader' do
    expect_offense(<<-RUBY.strip_indent)
      def self.foo
      ^^^ Use `attr_reader` to define trivial reader methods.
        @foo
      end
    RUBY
  end

  it 'registers an offense on class writer' do
    expect_offense(<<-RUBY.strip_indent)
      def self.foo(val)
      ^^^ Use `attr_writer` to define trivial writer methods.
        @foo = val
      end
    RUBY
  end

  it 'registers an offense on reader with braces' do
    expect_offense(<<-RUBY.strip_indent)
      def foo()
      ^^^ Use `attr_reader` to define trivial reader methods.
        @foo
      end
    RUBY
  end

  it 'registers an offense on writer without braces' do
    expect_offense(<<-RUBY.strip_indent)
      def foo= val
      ^^^ Use `attr_writer` to define trivial writer methods.
        @foo = val
      end
    RUBY
  end

  it 'registers an offense on one-liner reader' do
    expect_offense(<<-RUBY.strip_indent)
      def foo; @foo; end
      ^^^ Use `attr_reader` to define trivial reader methods.
    RUBY
  end

  it 'registers an offense on one-liner writer' do
    expect_offense(<<-RUBY.strip_indent)
      def foo(val); @foo=val; end
      ^^^ Use `attr_writer` to define trivial writer methods.
    RUBY
  end

  it 'registers an offense on DSL-style trivial writer' do
    expect_offense(<<-RUBY.strip_indent)
      def foo(val)
      ^^^ Use `attr_writer` to define trivial writer methods.
        @foo = val
      end
    RUBY
  end

  it 'registers an offense on reader with `private`' do
    expect_offense(<<-RUBY.strip_indent)
      private def foo
              ^^^ Use `attr_reader` to define trivial reader methods.
        @foo
      end
    RUBY
  end

  it 'accepts non-trivial reader' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def test
        some_function_call
        @test
      end
    RUBY
  end

  it 'accepts non-trivial writer' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def test(val)
        some_function_call(val)
        @test = val
        log(val)
      end
    RUBY
  end

  it 'accepts splats' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def splatomatic(*values)
        @splatomatic = values
      end
    RUBY
  end

  it 'accepts blocks' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def something(&block)
        @b = block
      end
    RUBY
  end

  it 'accepts expressions within reader' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def bar
        @bar + foo
      end
    RUBY
  end

  it 'accepts expressions within writer' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def bar(val)
        @bar = val + foo
      end
    RUBY
  end

  it 'accepts an initialize method looking like a writer' do
    expect_no_offenses(<<-RUBY.strip_indent)
       def initialize(value)
         @top = value
       end
    RUBY
  end

  it 'accepts reader with different ivar name' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        @fo
      end
    RUBY
  end

  it 'accepts writer with different ivar name' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo(val)
        @fo = val
      end
    RUBY
  end

  it 'accepts writer in a module' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module Foo
        def bar=(bar)
          @bar = bar
        end
      end
    RUBY
  end

  it 'accepts writer nested within a module' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module Foo
        begin
          def bar=(bar)
            @bar = bar
          end
        end
      end
    RUBY
  end

  it 'accepts reader nested within a module' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module Foo
        begin
          def bar
            @bar
          end
        end
      end
    RUBY
  end

  it 'accepts writer nested within an instance_eval call' do
    expect_no_offenses(<<-RUBY.strip_indent)
      something.instance_eval do
        begin
          def bar=(bar)
            @bar = bar
          end
        end
      end
    RUBY
  end

  it 'accepts reader nested within an instance_eval calll' do
    expect_no_offenses(<<-RUBY.strip_indent)
      something.instance_eval do
        begin
          def bar
            @bar
          end
        end
      end
    RUBY
  end

  it 'flags a reader inside a class, inside an instance_eval call' do
    expect_offense(<<-RUBY.strip_indent)
      something.instance_eval do
        class << @blah
          begin
            def bar
            ^^^ Use `attr_reader` to define trivial reader methods.
              @bar
            end
          end
        end
      end
    RUBY
  end
  context 'exact name match disabled' do
    let(:cop_config) { { 'ExactNameMatch' => false } }

    it 'registers an offense when names mismatch in writer' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(val)
        ^^^ Use `attr_writer` to define trivial writer methods.
          @f = val
        end
      RUBY
    end

    it 'registers an offense when names mismatch in reader' do
      expect_offense(<<-RUBY.strip_indent)
        def foo
        ^^^ Use `attr_reader` to define trivial reader methods.
          @f
        end
      RUBY
    end
  end

  context 'disallow predicates' do
    let(:cop_config) { { 'AllowPredicates' => false } }

    it 'does not accept predicate-like reader' do
      expect_offense(<<-RUBY.strip_indent)
        def foo?
        ^^^ Use `attr_reader` to define trivial reader methods.
          @foo
        end
      RUBY
    end
  end

  context 'allow predicates' do
    let(:cop_config) { { 'AllowPredicates' => true } }

    it 'accepts predicate-like reader' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo?
          @foo
        end
      RUBY
    end
  end

  context 'with whitelist' do
    let(:cop_config) { { 'Whitelist' => ['to_foo', 'bar='] } }

    it 'accepts whitelisted reader' do
      expect_no_offenses(<<-RUBY.strip_indent)
         def to_foo
           @foo
         end
      RUBY
    end

    it 'accepts whitelisted writer' do
      expect_no_offenses(<<-RUBY.strip_indent)
         def bar=(bar)
           @bar = bar
         end
      RUBY
    end

    context 'with AllowPredicates: false' do
      let(:cop_config) do
        { 'AllowPredicates' => false,
          'Whitelist' => ['foo?'] }
      end

      it 'accepts whitelisted predicate' do
        expect_no_offenses(<<-RUBY.strip_indent)
           def foo?
             @foo
           end
        RUBY
      end
    end
  end

  context 'with DSL allowed' do
    let(:cop_config) { { 'AllowDSLWriters' => true } }

    it 'accepts DSL-style writer' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo(val)
         @foo = val
        end
      RUBY
    end
  end

  context 'ignore class methods' do
    let(:cop_config) { { 'IgnoreClassMethods' => true } }

    it 'accepts class reader' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.foo
          @foo
        end
      RUBY
    end

    it 'accepts class writer' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.foo(val)
          @foo = val
        end
      RUBY
    end
  end

  describe '#autocorrect' do
    context 'trivial reader' do
      let(:source) { <<-RUBY.strip_indent }
        def foo
          @foo
        end
      RUBY

      let(:corrected_source) { "attr_reader :foo\n" }

      it 'autocorrects' do
        expect(autocorrect_source(source)).to eq(corrected_source)
      end
    end

    context 'with `private`' do
      let(:source) { <<-RUBY.strip_indent }
        private def foo
          @foo
        end
      RUBY

      it 'does not autocorrect' do
        expect(autocorrect_source(source)).to eq(source)
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'non-matching reader' do
      let(:cop_config) { { 'ExactNameMatch' => false } }

      let(:source) do
        <<-RUBY.strip_indent
          def foo
            @bar
          end
        RUBY
      end

      it 'does not autocorrect' do
        expect(autocorrect_source(source)).to eq(source)
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'predicate reader, with AllowPredicates: false' do
      let(:cop_config) { { 'AllowPredicates' => false } }
      let(:source) do
        <<-RUBY.strip_indent
          def foo?
            @foo
          end
        RUBY
      end

      it 'does not autocorrect' do
        expect(autocorrect_source(source)).to eq(source)
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'trivial writer' do
      let(:source) { <<-RUBY.strip_indent }
        def foo=(val)
          @foo = val
        end
      RUBY

      let(:corrected_source) { "attr_writer :foo\n" }

      it 'autocorrects' do
        expect(autocorrect_source(source)).to eq(corrected_source)
      end
    end

    context 'matching DSL-style writer' do
      let(:source) do
        <<-RUBY.strip_indent
          def foo(f)
            @foo=f
          end
        RUBY
      end

      it 'does not autocorrect' do
        expect(autocorrect_source(source)).to eq(source)
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'explicit receiver writer' do
      let(:source) do
        <<-RUBY.strip_indent
          def derp.foo=(f)
            @foo=f
          end
        RUBY
      end

      it 'does not autocorrect' do
        expect(autocorrect_source(source)).to eq(source)
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'class receiver reader' do
      let(:source) do
        <<-RUBY.strip_indent
          class Foo
            def self.foo
              @foo
            end
          end
        RUBY
      end

      let(:corrected_source) do
        <<-RUBY.strip_indent
          class Foo
            class << self
              attr_reader :foo
            end
          end
        RUBY
      end

      it 'autocorrects with class-level attr_reader' do
        expect(autocorrect_source(source)).to eq(corrected_source)
      end
    end

    context 'class receiver writer' do
      let(:source) do
        <<-RUBY.strip_indent
          class Foo
            def self.foo=(f)
              @foo = f
            end
          end
        RUBY
      end

      let(:corrected_source) do
        <<-RUBY.strip_indent
          class Foo
            class << self
              attr_writer :foo
            end
          end
        RUBY
      end

      it 'autocorrects with class-level attr_writer' do
        expect(autocorrect_source(source)).to eq(corrected_source)
      end
    end
  end
end
