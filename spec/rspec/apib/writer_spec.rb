require 'spec_helper'

describe RSpec::Apib::Writer do
  let(:example)   { double() }
  let(:request)   { double() }
  let(:response)  { double() }
  let(:routes)    { double() }
  let(:doc)       { {} }

  subject { described_class.new(doc) }

  it { should respond_to :write }

  describe '#write' do
    before :each do
      allow(subject).to receive(:pre_docs).and_return 'pre_docs'
      allow(subject).to receive(:build).and_return 'build'
      allow(subject).to receive(:post_docs).and_return 'post_docs'
      allow(subject).to receive :write_to_file
    end

    it 'calls #pre_docs' do
      expect(subject).to receive :pre_docs
      subject.write
    end

    it 'calls #build' do
      expect(subject).to receive :build
      subject.write
    end

    it 'calls #post_docs' do
      expect(subject).to receive :post_docs
      subject.write
    end

    it 'calls #write_to_file with generated data' do
      expect(subject).to receive(:write_to_file)
        .with("pre_docs\n\nbuild\n\npost_docs")
      subject.write
    end
  end

  describe '#write_to_file' do
    it 'opens the configured file' do
      allow(RSpec::Apib.config).to receive(:dest_file).and_return 'foo'
      expect(File).to receive(:open).with('foo', 'w')
      subject.send :write_to_file, ''
    end

    it 'writes the given data to the opened file' do
      file = double()
      allow(File).to receive(:open).and_yield file
      expect(file).to receive(:write).with('foo')
      subject.send :write_to_file, 'foo'
    end
  end

  pending '#write_to_file'
  pending '#pre_docs'
  pending '#post_docs'
  pending '#build'
end
