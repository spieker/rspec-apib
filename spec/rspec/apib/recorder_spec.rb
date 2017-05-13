require 'spec_helper'

describe RSpec::Apib::Recorder do
  def stub_request(env = {})
    ip_app = ActionDispatch::RemoteIp.new(Proc.new {})
    ip_app.call(env)
    ActionDispatch::Request.new(env)
  end

  let(:example)   { double() }
  let(:response)  { double() }
  let(:routes)    { ActionDispatch::Routing::RouteSet.new }
  let(:mapper)    { ActionDispatch::Routing::Mapper.new routes }
  let(:doc)       { {} }
  let(:request)   { stub_request "SCRIPT_NAME" => "", "PATH_INFO" => "/foo/5", "REQUEST_METHOD" => "GET" }

  subject { described_class.new(example, request, response, routes, doc) }

  it { should respond_to :run }

  describe '#run' do
    before :each do
      allow(subject).to receive(:document_request)
      allow(subject).to receive(:document_response)
    end

    context 'when request is nil' do
      let(:request) { nil }
      let(:response) { true }

      it 'is not calling #document_request' do
        expect(subject).to_not receive(:document_request)
        subject.run
      end

      it 'is not calling #document_response' do
        expect(subject).to_not receive(:document_response)
        subject.run
      end
    end

    context 'when response is nil' do
      let(:request) { true }
      let(:response) { nil }

      it 'is not calling #document_request' do
        expect(subject).to_not receive(:document_request)
        subject.run
      end

      it 'is not calling #document_response' do
        expect(subject).to_not receive(:document_response)
        subject.run
      end
    end

    it 'calls #document_request' do
      expect(subject).to receive(:document_request)
      subject.run
    end

    it 'calls #document_response' do
      expect(subject).to receive(:document_response)
      subject.run
    end
  end

  pending '#initialize'
  pending '#request_header_blacklist'
  pending '#request_param_blacklist'
  pending '#route'
  pending '#example_group'

  describe '#path' do
    it 'highlights required parts' do
      mapper.get "/foo/:id", to: "foo#bar", as: "baz"
      expect(subject.send(:path)).to eql '/foo/{id}(.{format})'
    end

    it 'highlights optional parts' do
      mapper.get "/foo/(:id)", to: "foo#bar", as: "baz"
      expect(subject.send(:path)).to eql '/foo(/{id})(.{format})'
    end
  end

  pending '#group'
  pending '#resource_type'
  pending '#resource_name'
  pending '#action'
  pending '#document_request'
  pending '#document_request_header'
  pending '#document_response'
  pending '#response_exists?'
end
