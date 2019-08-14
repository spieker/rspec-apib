require 'rails'
require 'rspec/apib/version'
require 'rspec/apib/configuration'
require 'rspec/apib/comments_parser'
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
        RSpec.configure do |config|
          config.after :each do |example|
            if RSpec::Apib.record?(example)
              RSpec::Apib.record(example, request, response, @routes)
            end
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

      def record?(example)
        default_recording_policy = config.default_recording_policy
        config.record_types.include?(example.metadata[:type]) &&
          (
            default_recording_policy && !(example.metadata[:apib] === false) ||
            !default_recording_policy && (example.metadata[:apib] === true)
          )
      end
    end
  end
end
