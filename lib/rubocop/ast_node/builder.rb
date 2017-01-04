# frozen_string_literal: true

module RuboCop
  class Node
    # `RuboCop::Builder` is an AST builder that is utilized to let `Parser`
    # generate ASTs with {RuboCop::Node}.
    #
    # @example
    #   buffer = Parser::Source::Buffer.new('(string)')
    #   buffer.source = 'puts :foo'
    #
    #   builder = RuboCop::Builder.new
    #   parser = Parser::CurrentRuby.new(builder)
    #   root_node = parser.parse(buffer)
    class Builder < Parser::Builders::Default
      # Generates {Node} from the given information.
      #
      # @return [Node] the generated node
      def n(type, children, source_map)
        node_map(type).new(type, children, location: source_map)
      end

      # TODO: Figure out what to do about literal encoding handling...
      # More details here https://github.com/whitequark/parser/issues/283
      def string_value(token)
        value(token)
      end

      def node_map(type)
        case type
        when :array then RuboCop::NodeExtension::ArrayNode
        when :hash  then RuboCop::NodeExtension::HashNode
        when :if    then RuboCop::NodeExtension::IfNode
        when :until, :until_post then RuboCop::NodeExtension::UntilNode
        when :while, :while_post then RuboCop::NodeExtension::WhileNode
        else Node
        end
      end
    end
  end
end
