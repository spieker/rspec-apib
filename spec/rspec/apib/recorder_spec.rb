require 'spec_helper'

describe RSpec::Apib::Recorder do
  def stub_request(env = {})
    ip_app = ActionDispatch::RemoteIp.new(Proc.new {})
    ip_app.call(env)
    ActionDispatch::Request.new(env)
  end

  let(:example) do
    double(
      metadata: {
        example_group: {}
      },
      description: 'foo example'
    )
  end

  let(:response) do
    double(
      status: 200,
      content_type: 'application/json',
      body: '{}',
      headers: {}
    )
  end

  let(:routes)    { ActionDispatch::Routing::RouteSet.new }
  let(:mapper)    { ActionDispatch::Routing::Mapper.new routes }
  let(:doc)       { {} }

  let(:request) do
    request = stub_request(
      "SCRIPT_NAME" => "",
      "PATH_INFO" => "/foo/5",
      "REQUEST_METHOD" => "GET",
      "HTTP_ORIGIN" => "foobar",
      "rack.input" => StringIO.new('{}')
    )
  end

  subject { described_class.new(example, request, response, routes, doc) }

  before :each do
    routes.draw do
      get '/foo/:id' => 'foo#bar'
    end
  end

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

  describe '#document_request_header' do
    it 'records headers' do
      action = subject.tap { |s| s.run }.send(:action)
      expect(action[:request][:headers]['origin']).to eql 'foobar'
    end

    it 'is not recording empty headers' do
      request = stub_request(
        "SCRIPT_NAME" => "",
        "PATH_INFO" => "/foo/5",
        "REQUEST_METHOD" => "GET",
        "HTTP_ORIGIN" => "",
        "rack.input" => StringIO.new('{}')
      )
      subject = described_class.new(example, request, response, routes, doc)
      action = subject.tap { |s| s.run }.send(:action)
      expect(action[:request][:headers]).to_not have_key 'origin'
    end
  end

  describe '#document_extended_description' do
    context 'only response description is included' do
      # --- apib:response
      # This is a comment used as description.
      # ---
      it 'replaces the description with the comment above the example' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        data   = action[:response].first
        expect(data[:description]).to eql 'This is a comment used as description.'
      end

      # --- apib:response
      # foo
      # bar
      # ---
      it 'handles multi line comments' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        data   = action[:response].first
        expect(data[:description]).to eql "foo\nbar"
      end

      # ABC
      #
      # --- apib:response
      # foo
      # bar
      # ---
      #
      # CDE
      #
      it 'ignores surrounding comments' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        data   = action[:response].first
        expect(data[:description]).to eql "foo\nbar"
      end

      # ABC
      #
      # --- apib:response
      # foo
      # bar
      #
      # CDE
      #
      it 'works without ending string' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        data   = action[:response].first
        expect(data[:description]).to eql "foo\nbar\n\nCDE\n"
      end

      # --- apib:response
      # ### foo
      it 'is not stripping out markdown control characters' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        data   = action[:response].first
        expect(data[:description]).to eql "### foo"
      end

      # --- apib:response
      # foobar
      # ------
      # hello
      it 'is accepts headline underscores' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        data   = action[:response].first
        expect(data[:description]).to eql "foobar\n------\nhello"
      end

      # --- apib:response
      # + foobar
      #     + hello
      it 'keeps subsequent indentation' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        data   = action[:response].first
        expect(data[:description]).to eql "+ foobar\n    + hello"
      end
    end

    context 'both request and response have description' do
      # --- apib:request
      # Request comment
      # --- apib:response
      # Response comment
      # ---
      it 'saves request description if we have a request and response description' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        request_data  = action[:request]
        response_data = action[:response].first
        expect(response_data[:description]).to eql 'Response comment'
        expect(request_data[:description]).to eql 'Request comment'
      end

      # --- apib:request
      # Request comment
      # ---
      it 'saves request description if we have only a request description' do |example|
        subject = described_class.new(example, request, response, routes, doc)
        action = subject.tap { |s| s.run }.send(:action)
        request_data = action[:request]
        expect(request_data[:description]).to eql 'Request comment'
      end
    end
  end

  pending '#document_response'
  pending '#response_exists?'
end
