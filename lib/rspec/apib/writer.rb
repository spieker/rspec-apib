module RSpec
  module Apib
    class Writer
      def initialize(doc)
        @apib = doc
      end

      def write
        data = []
        data << pre_docs
        data << build
        data << post_docs
        write_to_file data.join("\n\n")
      end

      private

      def write_to_file(data)
        File.open(RSpec::Apib.config.dest_file, 'w') do |file|
          file.write(data)
        end
      end

      def pre_docs
        RSpec::Apib.config.pre_docs.map { |f| File.read(f) }.join("\n\n")
      end

      def post_docs
        RSpec::Apib.config.post_docs.map { |f| File.read(f) }.join("\n\n")
      end

      def build
        apib = ""

        @apib.each do |group_name, group|
          apib += "# Group #{group_name}\n\n"
          group.each do |action, data|
            apib += "## #{action}\n\n"

            if data[:request][:params] && data[:request][:params].length > 0
              apib += "+ Parameters\n\n"
              data[:request][:params].each do |name, param|
                required = param[:required] ? 'required' : 'optional'
                value    = param[:value]
                apib += "    + #{name} (#{required}, string, `#{value}`) ...\n"
              end
              apib += "\n"
            end

            apib += "+ Request\n\n"
            apib += "    + Headers\n\n"
            data[:request][:headers].each do |header, value|
              apib += "            #{header}: #{value}\n"
            end
            apib += "\n"
            unless data[:request][:body].blank?
              apib += "    + Body\n\n"
              apib += data[:request][:body].to_s.indent(12)
              apib += "\n\n"
            end
            data[:response].sort { |a, b| a[:status] - b[:status] }.each do |response|
              apib += "+ Response #{response[:status]}\n\n"
              apib += "    #{response[:description]}\n\n"
              apib += "    + Headers\n\n"
              response[:headers].each do |header, value|
                apib += "            #{header}: #{value}\n"
              end
              apib += "\n"
              unless response[:body].blank?
                apib += "    + Body\n\n"
                apib += response[:body].to_s.indent(12)
                apib += "\n\n"
              end
            end
          end
        end

        apib
      end
    end
  end
end
