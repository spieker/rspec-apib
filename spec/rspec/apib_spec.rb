require 'spec_helper'

describe RSpec::Apib do
  let(:ex) { double(metadata: { type: :request }) }

  it 'has a version number' do
    expect(RSpec::Apib::VERSION).not_to be nil
  end

  # Method existence
  it { should respond_to :configure }
  it { should respond_to :config }
  it { should respond_to :start }

  describe '#config' do
    it 'returns a Configuration' do
      expect(RSpec::Apib.config).to be_instance_of RSpec::Apib::Configuration
    end

    it 'always returns the same configuration' do
      config = RSpec::Apib.config
      expect(RSpec::Apib.config).to eq config
    end
  end

  describe '#configure' do
    it 'passes the Gem configuration to a block' do
      RSpec::Apib.configure do |config|
        expect(config).to be_instance_of RSpec::Apib::Configuration
      end
    end

    it 'stores the configuration' do
      configuration = nil
      RSpec::Apib.configure do |config|
        configuration = config
      end

      expect(RSpec::Apib.instance_variable_get '@config').to eq configuration
    end
  end

  describe '#start' do
    let(:config) { double() }

    before :each do
      allow(RSpec).to receive(:configure).and_yield(config)
      allow(config).to receive(:after)
    end

    it 'calls #configure on RSpec' do
      expect(RSpec).to receive(:configure)
      RSpec::Apib.start
    end

    it 'creates an after_each callback' do
      expect(config).to receive(:after).with :each
      RSpec::Apib.start
    end

    it 'creates an after_all callback' do
      expect(config).to receive(:after).with :all
      RSpec::Apib.start
    end

    describe 'after(:each)' do
      it 'calls #record' do
        allow(config).to receive(:after).with(:each) do |arg, &block|
          expect(RSpec::Apib).to receive(:record).with(ex, 'foo', 'bar', 'baz')
          context = double(request: 'foo', response: 'bar')
          context.instance_variable_set :'@routes', 'baz'
          context.instance_exec(ex, &block)
        end
        RSpec::Apib.start
      end

      it 'is not calling #record for different example types' do
        ex.metadata[:type] = :something
        allow(config).to receive(:after).with(:each) do |arg, &block|
          expect(RSpec::Apib).to_not receive(:record)
          context = double(request: 'foo', response: 'bar')
          context.instance_variable_set :'@routes', 'baz'
          context.instance_exec(ex, &block)
        end
        RSpec::Apib.start
      end

      it 'if drp is not set, is not calling #record' do
        allow(RSpec::Apib.config).to receive(:default_recording_policy).and_return false
        allow(config).to receive(:after).with(:each) do |arg, &block|
          expect(RSpec::Apib).to_not receive(:record)
          context = double(request: 'foo', response: 'bar')
          context.instance_variable_set :'@routes', 'baz'
          context.instance_exec(ex, &block)
        end
        RSpec::Apib.start
      end

      it 'if drp is not set but apib is true, is calling #record' do
        allow(RSpec::Apib.config).to receive(:default_recording_policy).and_return false
        ex.metadata[:apib] = true
        allow(config).to receive(:after).with(:each) do |arg, &block|
          expect(RSpec::Apib).to receive(:record)
          context = double(request: 'foo', response: 'bar')
          context.instance_variable_set :'@routes', 'baz'
          context.instance_exec(ex, &block)
        end
        RSpec::Apib.start
      end

      it 'if drp is set but apib is false, is not calling #record' do
        allow(RSpec::Apib.config).to receive(:default_recording_policy).and_return true
        ex.metadata[:apib] = false
        allow(config).to receive(:after).with(:each) do |arg, &block|
          expect(RSpec::Apib).to_not receive(:record)
          context = double(request: 'foo', response: 'bar')
          context.instance_variable_set :'@routes', 'baz'
          context.instance_exec(ex, &block)
        end
        RSpec::Apib.start
      end

      it 'if drp is set, is calling #record' do
        allow(RSpec::Apib.config).to receive(:default_recording_policy).and_return true
        allow(config).to receive(:after).with(:each) do |arg, &block|
          expect(RSpec::Apib).to receive(:record)
          context = double(request: 'foo', response: 'bar')
          context.instance_variable_set :'@routes', 'baz'
          context.instance_exec(ex, &block)
        end
        RSpec::Apib.start
      end
    end

    describe 'after(:all)' do
      let(:ex) { double() }

      it 'calls #write' do
        allow(config).to receive(:after).with(:all) do |arg, &block|
          expect(RSpec::Apib).to receive(:write)
          context = double()
          context.instance_exec(&block)
        end
        RSpec::Apib.start
      end
    end
  end

  describe '#record' do
    it 'sets the instance variable @_doc' do
      RSpec::Apib.record(nil, nil, nil, nil)
      expect(RSpec::Apib.instance_variable_get :'@_doc').to eql({})
    end

    it 'creates a new recorder' do
      expect(RSpec::Apib::Recorder).to receive(:new).with(
        'example', 'request', 'response', 'routes', {}
      ).and_return double(run: nil)
      RSpec::Apib.record('example', 'request', 'response', 'routes')
    end

    it 'calls #run on the recorder' do
      recorder = double()
      allow(RSpec::Apib::Recorder).to receive(:new).and_return recorder
      expect(recorder).to receive :run
      RSpec::Apib.record(nil, nil, nil, nil)
    end
  end

  describe '#write' do
    it 'creates a new writer' do
      expect(RSpec::Apib::Writer).to receive(:new).with({})
        .and_return double(write: nil)
      RSpec::Apib.write
    end

    it 'calls #write on the writer' do
      writer = double()
      allow(RSpec::Apib::Writer).to receive(:new).and_return writer
      expect(writer).to receive :write
      RSpec::Apib.write
    end
  end

  describe '#record?' do
    it 'when drp is set, it returns true' do
      allow(RSpec::Apib.config).to receive(:default_recording_policy).and_return true
      expect(RSpec::Apib.record?(ex)).to be true
    end

    it 'when drp is set and apib is false, it returns false' do
      allow(RSpec::Apib.config).to receive(:default_recording_policy).and_return true
      ex.metadata[:apib] = false
      expect(RSpec::Apib.record?(ex)).to be false
    end

    it 'when drp is not set and apib is true, it returns true' do
      allow(RSpec::Apib.config).to receive(:default_recording_policy).and_return false
      ex.metadata[:apib] = true
      expect(RSpec::Apib.record?(ex)).to be true
    end

    it 'when drp is not set, it returns false' do
      allow(RSpec::Apib.config).to receive(:default_recording_policy).and_return false
      expect(RSpec::Apib.record?(ex)).to be false
    end
  end
end
