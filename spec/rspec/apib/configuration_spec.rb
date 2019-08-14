require 'spec_helper'

describe RSpec::Apib::Configuration do
  # Method existence
  it { should respond_to :dest_file }
  it { should respond_to :dest_file= }
  it { should respond_to :pre_docs }
  it { should respond_to :pre_docs= }
  it { should respond_to :post_docs }
  it { should respond_to :post_docs= }
  it { should respond_to :request_header_blacklist }
  it { should respond_to :request_header_blacklist= }
  it { should respond_to :request_param_blacklist }
  it { should respond_to :request_param_blacklist= }
  it { should respond_to :inclusion_policy }
  it { should respond_to :inclusion_policy= }

  describe '#dest_file' do
    it 'equals the rails root by default' do
      allow(Rails).to receive(:root).and_return './'
      expect(subject.dest_file).to eql './apiary.apib'
    end

    it 'returns the given value' do
      subject.dest_file = 'foo'
      expect(subject.dest_file).to eql 'foo'
    end
  end

  describe '#pre_docs' do
    it 'is an array' do
      expect(subject.pre_docs).to be_kind_of Array
    end

    it 'is an array when string given' do
      subject.pre_docs = 'foo'
      expect(subject.pre_docs).to be_kind_of Array
    end

    it 'contains the given string' do
      subject.pre_docs = 'foo'
      expect(subject.pre_docs).to include 'foo'
    end

    it 'equals the given value if it was an array' do
      subject.pre_docs = ['foo', 'bar']
      expect(subject.pre_docs).to eql ['foo', 'bar']
    end
  end


  describe '#post_docs' do
    it 'is an array' do
      expect(subject.post_docs).to be_kind_of Array
    end

    it 'is an array when string given' do
      subject.post_docs = 'foo'
      expect(subject.post_docs).to be_kind_of Array
    end

    it 'contains the given string' do
      subject.post_docs = 'foo'
      expect(subject.post_docs).to include 'foo'
    end

    it 'equals the given value if it was an array' do
      subject.post_docs = ['foo', 'bar']
      expect(subject.post_docs).to eql ['foo', 'bar']
    end
  end

  describe '#record_types' do
    it 'is an array' do
      expect(subject.record_types).to be_kind_of Array
    end

    it 'is an array when symbol given' do
      subject.record_types = :foo
      expect(subject.record_types).to be_kind_of Array
    end

    it 'contains the given symbol' do
      subject.record_types = :foo
      expect(subject.record_types).to include :foo
    end

    it 'equals the given value if it was an array' do
      subject.record_types = [:foo, :bar]
      expect(subject.record_types).to eql [:foo, :bar]
    end
  end

  describe '#inclusion_policy' do
    it 'is a symbol' do
      expect(subject.inclusion_policy).to be_kind_of Symbol
    end

    it 'contains the given symbol' do
      subject.inclusion_policy = :all
      expect(subject.inclusion_policy).to eql :all
    end
  end
end
