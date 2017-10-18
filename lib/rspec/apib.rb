require 'rails'
require 'rspec/apib/version'
require 'rspec/apib/configuration'
require 'rspec/apib/recorder'
require 'rspec/apib/writer'

module RSpec
  module Apib
    class <<self
      def configure
        @config = Configuration.new
        yield(@config) if block_given?
        @config
      end

      def config
        @config || configure
      end

      def connection
        Connection.instance
      end

      def start
        types = config.record_types
        RSpec.configure do |config|
          config.after :each do |example|
            return if example.metadata[:apib] === false
            return unless types.include?(example.metadata[:type])
            RSpec::Apib.record(example, request, response, @routes)
          end

          config.after :all do |example|
            RSpec::Apib.write
          end
        end
      end

      def record(example, request, response, routes)
        @_doc ||= {}
        recorder = Recorder.new(example, request, response, routes, @_doc)
        recorder.run
      end

      def write
        writer = Writer.new(@_doc || {})
        writer.write
      end
    end
  end
end
