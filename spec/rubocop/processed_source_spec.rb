# frozen_string_literal: true

RSpec.describe RuboCop::ProcessedSource do
  include FileHelper

  subject(:processed_source) { described_class.new(source, ruby_version, path) }

  let(:ruby_version) { RuboCop::Config::KNOWN_RUBIES.last }

  let(:source) { <<-RUBY.strip_indent }
    # encoding: utf-8
    def some_method
      puts 'foo'
    end
    some_method
  RUBY

  let(:path) { 'path/to/file.rb' }

  describe '.from_file', :isolated_environment do
    describe 'when the file exists' do
      before do
        create_file(path, 'foo')
      end

      let(:processed_source) { described_class.from_file(path, ruby_version) }

      it 'returns an instance of ProcessedSource' do
        expect(processed_source.is_a?(described_class)).to be(true)
      end

      it "sets the file path to the instance's #path" do
        expect(processed_source.path).to eq(path)
      end
    end

    it 'raises RuboCop::Error when the file does not exist' do
      expect do
        described_class.from_file('foo', ruby_version)
      end.to raise_error(RuboCop::Error)
        .with_message(/No such file or directory/)
    end
  end

  describe '#path' do
    it 'is the path passed to .new' do
      expect(processed_source.path).to eq(path)
    end
  end

  describe '#buffer' do
    it 'is a source buffer' do
      expect(processed_source.buffer.is_a?(Parser::Source::Buffer)).to be(true)
    end
  end

  describe '#ast' do
    it 'is the root node of AST' do
      expect(processed_source.ast.is_a?(RuboCop::AST::Node)).to be(true)
    end
  end

  describe '#comments' do
    it 'is an array of comments' do
      expect(processed_source.comments.is_a?(Array)).to be(true)
      expect(
        processed_source.comments.first.is_a?(Parser::Source::Comment)
      ).to be(true)
    end
  end

  describe '#tokens' do
    it 'has an array of tokens' do
      expect(processed_source.tokens.is_a?(Array)).to be(true)
      expect(processed_source.tokens.first.is_a?(RuboCop::Token)).to be(true)
    end
  end

  shared_context 'invalid encoding source' do
    let(:source) do
      [
        '# encoding: utf-8',
        "# \xf9"
      ].join("\n")
    end
  end

  describe '#parser_error' do
    context 'when the source was properly parsed' do
      it 'is nil' do
        expect(processed_source.parser_error.nil?).to be(true)
      end
    end

    context 'when the source lacks encoding comment and is really utf-8 ' \
            'encoded but has been read as US-ASCII' do
      let(:source) do
        # When files are read into RuboCop, the encoding of source code
        # lacking an encoding comment will default to the external encoding,
        # which could for example be US-ASCII if the LC_ALL environment
        # variable is set to "C".
        '号码 = 3'.dup.force_encoding('US-ASCII')
      end

      it 'is nil' do
        # ProcessedSource#parse sets UTF-8 as default encoding, so no error.
        expect(processed_source.parser_error.nil?).to be(true)
      end
    end

    context 'when the source could not be parsed due to encoding error' do
      include_context 'invalid encoding source'

      it 'returns the error' do
        expect(processed_source.parser_error.is_a?(Exception)).to be(true)
        expect(processed_source.parser_error.message)
          .to include('invalid byte sequence')
      end
    end
  end

  describe '#lines' do
    it 'is an array' do
      expect(processed_source.lines.is_a?(Array)).to be(true)
    end

    it 'has same number of elements as line count' do
      # Since the source has a trailing newline, there is a final empty line
      expect(processed_source.lines.size).to eq(6)
    end

    it 'contains lines as string without linefeed' do
      first_line = processed_source.lines.first
      expect(first_line).to eq('# encoding: utf-8')
    end
  end

  describe '#[]' do
    context 'when an index is passed' do
      it 'returns the line' do
        expect(processed_source[3]).to eq('end')
      end
    end

    context 'when a range is passed' do
      it 'returns the array of lines' do
        expect(processed_source[3..4]).to eq(%w[end some_method])
      end
    end

    context 'when start index and length are passed' do
      it 'returns the array of lines' do
        expect(processed_source[3, 2]).to eq(%w[end some_method])
      end
    end
  end

  describe 'valid_syntax?' do
    subject { processed_source.valid_syntax? }

    context 'when the source is completely valid' do
      let(:source) { 'def valid_code; end' }

      it 'returns true' do
        expect(processed_source.diagnostics.empty?).to be(true)
        expect(processed_source.valid_syntax?).to be(true)
      end
    end

    context 'when the source is invalid' do
      let(:source) { 'def invalid_code; en' }

      it 'returns false' do
        expect(processed_source.valid_syntax?).to be(false)
      end
    end

    context 'when the source is valid but has some warning diagnostics' do
      let(:source) { 'do_something *array' }

      it 'returns true' do
        expect(processed_source.diagnostics.empty?).to be(false)
        expect(processed_source.diagnostics.first.level).to eq(:warning)
        expect(processed_source.valid_syntax?).to be(true)
      end
    end

    context 'when the source could not be parsed due to encoding error' do
      include_context 'invalid encoding source'

      it 'returns false' do
        expect(processed_source.valid_syntax?).to be(false)
      end
    end

    # https://github.com/whitequark/parser/issues/283
    context 'when the source itself is valid encoding but includes strange ' \
            'encoding literals that are accepted by MRI' do
      let(:source) do
        'p "\xff"'
      end

      it 'returns true' do
        expect(processed_source.diagnostics.empty?).to be(true)
        expect(processed_source.valid_syntax?).to be(true)
      end
    end

    context 'when a line starts with an integer literal' do
      let(:source) { '1 + 1' }

      # regression test
      it 'tokenizes the source correctly' do
        expect(processed_source.tokens[0].text).to eq '1'
      end
    end
  end

  context 'with heavily commented source' do
    let(:source) { <<-RUBY.strip_indent }
      def foo # comment one
        bar # comment two
      end # comment three
    RUBY

    describe '#each_comment' do
      it 'yields all comments' do
        comments = []

        processed_source.each_comment do |item|
          expect(item.is_a?(Parser::Source::Comment)).to be true
          comments << item
        end

        expect(comments.size).to eq 3
      end
    end

    describe '#find_comment' do
      it 'yields correct comment' do
        comment = processed_source.find_comment do |item|
          item.text == '# comment three'
        end

        expect(comment.text).to eq '# comment three'
      end

      it 'yields nil when there is no match' do
        comment = processed_source.find_comment do |item|
          item.text == '# comment four'
        end

        expect(comment).to eq nil
      end
    end
  end

  context 'token enumerables' do
    let(:source) { <<-RUBY.strip_indent }
      foo(1, 2)
    RUBY

    describe '#each_token' do
      it 'yields all tokens' do
        tokens = []

        processed_source.each_token do |item|
          expect(item.is_a?(RuboCop::Token)).to be true
          tokens << item
        end

        expect(tokens.size).to eq 7
      end
    end

    describe '#find_token' do
      it 'yields correct token' do
        token = processed_source.find_token(&:comma?)

        expect(token.text).to eq ','
      end

      it 'yields nil when there is no match' do
        token = processed_source.find_token(&:right_bracket?)

        expect(token).to eq nil
      end
    end
  end

  describe '#file_path' do
    it 'returns file path' do
      expect(processed_source.file_path).to eq 'path/to/file.rb'
    end
  end

  describe '#blank?' do
    context 'with source of no content' do
      let(:source) { <<-RUBY.strip_indent }
      RUBY

      it 'returns true' do
        expect(processed_source.blank?).to eq true
      end
    end

    context 'with source with content' do
      let(:source) { <<-RUBY.strip_indent }
        foo
      RUBY

      it 'returns false' do
        expect(processed_source.blank?).to eq false
      end
    end
  end
end
