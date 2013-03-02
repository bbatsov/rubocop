# encoding: utf-8

module Rubocop
  module Cop
    module SurroundingSpace
      def inspect(file, source, tokens, sexp)
        @correlations.sort.each do |ix, grammar_path|
          check_missing_space(tokens, ix, grammar_path)
        end
        tokens.each_index { |ix| check_unwanted_space(tokens, ix) }
      end

      private

      def previous_non_space(tokens, ix)
        tokens[0...ix].reverse.find { |t| not whitespace?(t) }
      end

      def ok_without_spaces?(grammar_path)
        parent, child = grammar_path.values_at(-2, -1)
        return true if [:unary, :symbol, :defs, :def, :call].include?(parent)
        return true if [:**, :block_var].include?(child)
        parent == :command_call && child == :'::'
      end

      def surrounded_by_whitespace?(nearby_tokens)
        left, _, right = nearby_tokens
        whitespace?(left) && whitespace?(right)
      end

      # Default implementation for classes that don't need it.
      def check_missing_space(tokens, ix, grammar_path)
      end
    end

    class SpaceAroundOperators < Cop
      include SurroundingSpace
      ERROR_MESSAGE = 'Surrounding space missing for operator '

      def check_missing_space(tokens, ix, grammar_path)
        t = tokens[ix]
        if t.type == :on_op
          unless surrounded_by_whitespace?(tokens[ix - 1, 3])
            unless ok_without_spaces?(grammar_path)
              add_offence(:convention, t.pos.lineno,
                          ERROR_MESSAGE + "'#{t.text}'.")
            end
          end
        end
      end

      def check_unwanted_space(tokens, ix)
        prev, t, nxt = tokens.values_at(ix - 1, ix, ix + 1)
        if t.type == :on_op && t.text == '**' &&
            (whitespace?(prev) || whitespace?(nxt))
          add_offence(:convention, t.pos.lineno,
                      "Space around operator #{t.text} detected.")
        end
      end
    end

    class SpaceAroundBraces < Cop
      include SurroundingSpace

      def check_unwanted_space(tokens, ix)
      end

      def check_missing_space(tokens, ix, grammar_path)
        t = tokens[ix]
        case t.type
        when :on_lbrace
          unless surrounded_by_whitespace?(tokens[ix - 1, 3])
            add_offence(:convention, t.pos.lineno,
                        "Surrounding space missing for '{'.")
          end
        when :on_rbrace
          unless whitespace?(tokens[ix - 1])
            add_offence(:convention, t.pos.lineno,
                        "Space missing to the left of '}'.")
          end
        end
      end
    end

    module SpaceInside
      include SurroundingSpace

      Paren = Struct.new :left, :right, :kind

      def check_unwanted_space(tokens, ix)
        paren = get_paren
        prev, t, nxt = tokens.values_at(ix - 1, ix, ix + 1)
        offence_detected = case t.type
                           when paren.left
                             nxt.type == :on_sp
                           when paren.right
                             if prev.type == :on_sp
                               prev_ns = previous_non_space(tokens, ix)
                               prev_ns &&
                                 prev_ns.pos.lineno == tokens[ix].pos.lineno &&
                                 # Avoid double reporting
                                 prev_ns.type != paren.left
                             end
                           end
        if offence_detected
          add_offence(:convention, t.pos.lineno,
                      "Space inside #{paren.kind} detected.")
        end
      end
    end

    class SpaceInsideParens < Cop
      include SpaceInside
      def get_paren
        Paren.new(:on_lparen, :on_rparen, 'parentheses')
      end
    end

    class SpaceInsideBrackets < Cop
      include SpaceInside
      def get_paren
        Paren.new(:on_lbracket, :on_rbracket, 'square brackets')
      end
    end

    class SpaceAroundEqualsInParameterDefault < Cop
      def inspect(file, source, tokens, sexp)
        each(:params, sexp) do |s|
          (s[2] || []).each do |param, value|
            value_pos = all_positions(value).first or next
            if param[-1].lineno == value_pos.lineno
              if value_pos.column - (param[-1].column + param[1].length) <= 2
                add_offence(:convention, param[-1].lineno,
                            'Surrounding space missing in default value ' +
                            'assignment.')
              end
            end
          end
        end
      end
    end
  end
end
