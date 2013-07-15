# encoding: utf-8

module Rubocop
  # SourceParser provides a way to parse Ruby source with Parser gem
  # and also parses comment directives which disable arbitrary cops.
  module SourceParser
    module_function

    def parse(string, name = '(string)')
      source_buffer = Parser::Source::Buffer.new(name, 1)
      source_buffer.source = string

      parser = create_parser
      source = string.split($RS)
      diagnostics = []
      parser.diagnostics.consumer = lambda do |diagnostic|
        diagnostics << diagnostic
      end

      begin
        ast, comments, tokens = parser.tokenize(source_buffer)
      rescue Parser::SyntaxError # rubocop:disable HandleExceptions
        # All errors are in diagnostics. No need to handle exception.
      end

      tokens = repack_tokens(tokens)

      [ast, comments, tokens, source_buffer, source, diagnostics]
    end

    def parse_file(path)
      parse(File.read(path), path)
    end

    def create_parser
      parser = Parser::CurrentRuby.new

      # On JRuby and Rubinius, there's a risk that we hang in
      # tokenize() if we don't set the all errors as fatal flag.
      parser.diagnostics.all_errors_are_fatal = RUBY_ENGINE != 'ruby'
      parser.diagnostics.ignore_warnings      = false

      parser
    end

    def repack_tokens(parser_tokens)
      return nil unless parser_tokens
      parser_tokens.map do |t|
        type, details = *t
        text, range = *details
        Cop::Token.new(range, type, text)
      end
    end

    COMMENT_DIRECTIVE_REGEXP = Regexp.new(
      '^.*?(\S)?.*# rubocop : ((?:dis|en)able)\b ((?:\w+,? )+)'
        .gsub(' ', '\s*')
    )

    def disabled_lines_in(source)
      disabled_lines = {}
      current_disabled_cops = {}

      source.each_with_index do |line, index|
        line_number = index + 1

        each_mentioned_cop(line) do |cop_name, disabled, single_line|
          if single_line
            next unless disabled
            disabled_lines[cop_name] ||= []
            disabled_lines[cop_name] << line_number
          else
            current_disabled_cops[cop_name] = disabled
          end
        end

        current_disabled_cops.each do |cop_name, disabled|
          next unless disabled
          disabled_lines[cop_name] ||= []
          disabled_lines[cop_name] << line_number
        end
      end

      disabled_lines
    end

    def each_mentioned_cop(line)
      match = line.match(COMMENT_DIRECTIVE_REGEXP)

      return unless match

      non_whitespace_before_comment, switch, cops_string = match.captures

      if cops_string.include?('all')
        cop_names = Cop::Cop.all.map(&:cop_name)
      else
        cop_names = cops_string.split(/,\s*/)
      end

      disabled = (switch == 'disable')
      single_line = !non_whitespace_before_comment.nil?

      cop_names.each { |cop_name| yield cop_name, disabled, single_line }
    end
  end
end
