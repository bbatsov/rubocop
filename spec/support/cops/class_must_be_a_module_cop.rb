# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      class ClassMustBeAModuleCop < RuboCop::Cop::Cop
        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.keyword, 'module') }
        end

        def on_class(node)
          add_offense(node, message: 'Class must be a Module')
        end
      end
    end
  end
end
