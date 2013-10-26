require 'spec_helper'

describe Rack::Subdomain do

  let(:app){ App.new }
  let(:domain){ 'example.com' }
  let(:options){ {to: 'foo'} }
  subject{ Rack::Subdomain.new(app, domain, options) }

  describe '#constraint' do
    context 'when subdomain is nil or empty' do
      it 'should return false' do
        subject.send(:constraint, nil, {}).should be_false
        subject.send(:constraint, '', {}).should be_false
      end
    end
    context 'when :only option is specified' do
      context 'when subdomain is in the :only condition' do
        it 'should return true' do
          subject.send(:constraint, 'foo', {only: %w(foo bar)}).should be_true
        end
        it 'should ignore the :except option' do
          subject.send(:constraint, 'foo', {only: %w(foo bar), except: %w(foo)}).should be_true
        end
      end
      context 'when subdomain not in the :only condition' do
        it 'should return false' do
          subject.send(:constraint, 'baz', {only: %w(foo bar)}).should be_false
        end
        it 'should ignore the :except option' do
          subject.send(:constraint, 'baz', {only: %w(foo bar), except: %w(bing)}).should be_false
        end
      end
    end
    context 'when :except option is specified' do
      context 'when subdomain is in the :except condition' do
        it 'should return false' do
          subject.send(:constraint, 'foo', {except: %w(foo bar)}).should be_false
        end
      end
      context 'when subdomain not in the :except condition' do
        it 'should return true' do
          subject.send(:constraint, 'baz', {except: %w(foo bar)}).should be_true
        end
      end
    end
  end

  describe '#prepare_options' do
    context 'when options are a String' do
      it 'should convert :to to Hash' do
        subject.send(:prepare_options, 'my_string').should eq(to: 'my_string', except: ['', 'www'])
      end
    end
    context 'when options includes :except' do
      context 'when :except is a String' do
        it 'should convert :except to Array' do
          subject.send(:prepare_options, except: 'foo').should eq(except: %w(foo))
        end
      end
      context 'when :except is an Array' do
        it 'should keep :except as-is' do
          subject.send(:prepare_options, except: %w(foo bar baz)).should eq(except: %w(foo bar baz))
        end
      end
    end
    context 'when options does not include :except' do
      it 'should set a default value for :except' do
        subject.send(:prepare_options, {}).should eq(except: ['', 'www'])
      end
    end
    context 'when options includes :only' do
      context 'when :only is a String' do
        it 'should convert :only to Array' do
          subject.send(:prepare_options, only: 'foo').should eq(only: %w(foo), except: ['', 'www'])
        end
      end
      context 'when :only is an Array' do
        it 'should keep :only as-is' do
          subject.send(:prepare_options, only: %w(foo bar baz)).should eq(only: %w(foo bar baz), except: ['', 'www'])
        end
      end
    end
  end
end
