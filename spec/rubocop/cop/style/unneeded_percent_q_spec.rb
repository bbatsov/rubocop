# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnneededPercentQ do
  subject(:cop) { described_class.new }

  context 'with %q strings' do
    it 'registers an offense for only single quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %q('hi')
        ^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY
    end

    it 'registers an offense for only double quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %q("hi")
        ^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY
    end

    it 'registers an offense for no quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %q(hi)
        ^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY
    end

    it 'accepts a string with single quotes and double quotes' do
      expect_no_offenses("%q('\"hi\"')")
    end

    it 'registers an offfense for a string containing escaped backslashes' do
      inspect_source('%q(\\\\foo\\\\)')

      expect(cop.messages.length).to eq 1
    end

    it 'accepts a string with escaped non-backslash characters' do
      expect_no_offenses("%q(\\'foo\\')")
    end

    it 'accepts a string with escaped backslash and non-backslash characters' do
      expect_no_offenses("%q(\\\\ \\'foo\\' \\\\)")
    end

    it 'accepts regular expressions starting with %q' do
      expect_no_offenses('/%q?/')
    end

    context 'auto-correct' do
      it 'registers an offense for only single quotes' do
        new_source = autocorrect_source("%q('hi')")

        expect(new_source).to eq(%q("'hi'"))
      end

      it 'registers an offense for only double quotes' do
        new_source = autocorrect_source('%q("hi")')

        expect(new_source).to eq(%q('"hi"'))
      end

      it 'registers an offense for no quotes' do
        new_source = autocorrect_source('%q(hi)')

        expect(new_source).to eq("'hi'")
      end

      it 'auto-corrects for strings that is concated with backslash' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          %q(foo bar baz) \
            'boogers'
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          'foo bar baz' \
            'boogers'
        RUBY
      end
    end
  end

  context 'with %Q strings' do
    it 'registers an offense for static string without quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %Q(hi)
        ^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY
    end

    it 'registers an offense for static string with only double quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %Q("hi")
        ^^^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY
    end

    it 'registers an offense for dynamic string without quotes' do
      expect_offense(<<-'RUBY'.strip_indent)
        %Q(hi#{4})
        ^^^^^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY
    end

    it 'accepts a string with single quotes and double quotes' do
      expect_no_offenses("%Q('\"hi\"')")
    end

    it 'accepts a string with double quotes and an escaped special character' do
      expect_no_offenses('%Q("\\thi")')
    end

    it 'accepts a string with double quotes and an escaped normal character' do
      expect_no_offenses('%Q("\\!thi")')
    end

    it 'accepts a dynamic %Q string with double quotes' do
      expect_no_offenses("%Q(\"hi\#{4}\")")
    end

    it 'accepts regular expressions starting with %Q' do
      expect_no_offenses('/%Q?/')
    end

    context 'auto-correct' do
      it 'corrects a static string without quotes' do
        new_source = autocorrect_source('%Q(hi)')

        expect(new_source).to eq('"hi"')
      end

      it 'corrects a static string with only double quotes' do
        new_source = autocorrect_source('%Q("hi")')

        expect(new_source).to eq(%q('"hi"'))
      end

      it 'corrects a dynamic string without quotes' do
        new_source = autocorrect_source("%Q(hi\#{4})")

        expect(new_source).to eq(%("hi\#{4}"))
      end

      it 'auto-corrects for strings that is concated with backslash' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          %Q(foo bar baz) \
            'boogers'
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          "foo bar baz" \
            'boogers'
        RUBY
      end
    end
  end

  it 'accepts a heredoc string that contains %q' do
    expect_no_offenses(<<-RUBY.strip_indent)
        s = <<CODE
      %q('hi') # line 1
      %q("hi")
      CODE
    RUBY
  end

  it 'accepts %q at the beginning of a double quoted string ' \
     'with interpolation' do
    inspect_source("\"%q(a)\#{b}\"")

    expect(cop.messages.empty?).to be(true)
  end

  it 'accepts %Q at the beginning of a double quoted string ' \
     'with interpolation' do
    inspect_source("\"%Q(a)\#{b}\"")

    expect(cop.messages.empty?).to be(true)
  end

  it 'accepts %q at the beginning of a section of a double quoted string ' \
     'with interpolation' do
    inspect_source(%("%\#{b}%q(a)"))

    expect(cop.messages.empty?).to be(true)
  end

  it 'accepts %Q at the beginning of a section of a double quoted string ' \
     'with interpolation' do
    inspect_source(%("%\#{b}%Q(a)"))

    expect(cop.messages.empty?).to be(true)
  end

  it 'accepts %q containing string interpolation' do
    expect_no_offenses("%q(foo \#{'bar'} baz)")
  end
end
