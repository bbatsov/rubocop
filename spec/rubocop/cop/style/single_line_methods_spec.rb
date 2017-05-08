# frozen_string_literal: true

describe RuboCop::Cop::Style::SingleLineMethods do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/SingleLineMethods' => cop_config,
                        'Layout/IndentationWidth' => { 'Width' => 2 })
  end
  let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

  it 'registers an offense for a single-line method' do
    expect_offense(<<-END.strip_indent)
      def some_method; body end
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def link_to(name, url); {:name => name}; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def @table.columns; super; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    END
  end

  context 'when AllowIfMethodIsEmpty is disabled' do
    let(:cop_config) { { 'AllowIfMethodIsEmpty' => false } }

    it 'registers an offense for an empty method' do
      inspect_source(cop, <<-END.strip_indent)
        def no_op; end
        def self.resource_class=(klass); end
        def @table.columns; end
      END
      expect(cop.offenses.size).to eq(3)
    end

    it 'auto-corrects an empty method' do
      corrected = autocorrect_source(cop, 'def x; end')
      expect(corrected).to eq(['def x; ',
                               'end'].join("\n"))
    end
  end

  context 'when AllowIfMethodIsEmpty is enabled' do
    let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

    it 'accepts a single-line empty method' do
      expect_no_offenses(<<-END.strip_indent)
        def no_op; end
        def self.resource_class=(klass); end
        def @table.columns; end
      END
    end
  end

  it 'accepts a multi-line method' do
    expect_no_offenses(<<-END.strip_indent)
      def some_method
        body
      end
    END
  end

  it 'does not crash on an method with a capitalized name' do
    expect_no_offenses(<<-END.strip_indent)
      def NoSnakeCase
      end
    END
  end

  it 'auto-corrects def with semicolon after method name' do
    corrected = autocorrect_source(cop,
                                   ['  def some_method; body end # Cmnt'])
    expect(corrected).to eq ['  # Cmnt',
                             '  def some_method; ',
                             '    body ',
                             '  end '].join("\n")
  end

  it 'auto-corrects defs with parentheses after method name' do
    corrected = autocorrect_source(cop, ['  def self.some_method() body end'])
    expect(corrected).to eq ['  def self.some_method() ',
                             '    body ',
                             '  end'].join("\n")
  end

  it 'auto-corrects def with argument in parentheses' do
    corrected = autocorrect_source(cop, ['  def some_method(arg) body end'])
    expect(corrected).to eq ['  def some_method(arg) ',
                             '    body ',
                             '  end'].join("\n")
  end

  it 'auto-corrects def with argument and no parentheses' do
    corrected = autocorrect_source(cop, ['  def some_method arg; body end'])
    expect(corrected).to eq ['  def some_method arg; ',
                             '    body ',
                             '  end'].join("\n")
  end

  it 'auto-corrects def with semicolon before end' do
    corrected = autocorrect_source(cop, ['  def some_method; b1; b2; end'])
    expect(corrected).to eq ['  def some_method; ',
                             '    b1; ',
                             '    b2; ',
                             '  end'].join("\n")
  end
end
