# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Encoding do
      let (:encoding) { Encoding.new }

      it 'registers an offence when no encoding present' do
        inspect_source(encoding, 'file.rb', ['def foo() end'])

        encoding.offences.map(&:message).should ==
          ['Missing encoding comment.']
      end

      it 'accepts encoding on first line' do
        inspect_source(encoding, 'file.rb', ['# encoding: utf-8',
                                             'def foo() end'])

        encoding.offences.should == []
      end

      it 'accepts encoding on second line when shebang present' do
        inspect_source(encoding, 'file.rb', ['#!/usr/bin/env ruby',
                                             '# encoding: utf-8',
                                             'def foo() end'])

        encoding.offences.map(&:message).should == []
      end

      it 'registers an offence when encoding is in the wrong place' do
        inspect_source(encoding, 'file.rb', ['def foo() end',
                                             '# encoding: utf-8'])

        encoding.offences.map(&:message).should ==
          ['Missing encoding comment.']
      end
    end
  end
end
