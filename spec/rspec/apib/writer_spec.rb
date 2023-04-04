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
      expect(File).to receive(:open).with('foo', 'wb')
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

  describe '#build' do
    let(:doc) do
      {
        'foo' => {
          'GET' => {
            request: {
              headers: {}
            },
            response: [doc_response]
          }
        },
        'baz' => {
          'GET' => {
            request: {
              headers: {}
            },
            response: [doc_response]
          }
        }
      }
    end

    let(:doc_response) do
      {
        status: 200,
        headers: {},
        description: "foo\nbar"
      }
    end

    it 'adds propper indentation to multi line descriptions' do
      result = subject.send :build
      expect(result).to include "    foo\n    bar"
    end

    it 'it works with a nil description' do
      doc_response[:description] = nil
      result = subject.send :build
      expect(result).to be_a String
    end

    it 'sorts the groups alphabetically' do
      doc_response[:description] = nil
      result = subject.send :build
      pos_foo = result.index('# Group foo')
      pos_baz = result.index('# Group baz')
      expect(pos_baz).to be < pos_foo
    end
  end
end
