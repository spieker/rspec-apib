require 'spec_helper'

describe RSpec::Apib::CommentsParser do
  describe '#full_comment' do
    # ABC
    #
    # --- apib:response
    # foo
    # bar
    # ---
    #
    # CDE
    #
    it 'returns the full comment of the example' do |example|
      subject = described_class.new(example)
      expect(subject.full_comment).to eql [
        "ABC",
        "",
        "--- apib:response",
        "foo",
        "bar",
        "---",
        "",
        "CDE",
        "",
      ]
    end
  end

  describe '#description' do
    # ABC
    #
    # --- apib:response
    # foo
    # bar
    # --- apib
    # baz
    # ---
    #
    # CDE
    #
    it 'without a namespace, returns the `apib` comment' do |example|
      subject = described_class.new(example)
      expect(subject.description).to eql "baz"
    end

    # ABC
    #
    # --- apib:request
    # foo
    # bar
    # --- apib
    # baz
    # ---
    #
    # CDE
    #
    it 'with a namespace, returns the `apib:NAMESPACE` comment' do |example|
      subject = described_class.new(example)
      expect(subject.description("request")).to eql "foo\nbar"
    end

    # --- apib
    # FooBar
    # ------
    # Baz
    # ---
    it 'is not exiting on markdown headlines' do |example|
      subject = described_class.new(example)
      expect(subject.description).to eql "FooBar\n------\nBaz"
    end
  end
end
