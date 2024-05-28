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
        File.open(RSpec::Apib.config.dest_file, 'wb') do |file|
          file.write(data)
        end
      end

      def pre_docs
        RSpec::Apib.config.pre_docs.map { |f| File.read(f) }.join("\n\n")
      end

      def post_docs
        RSpec::Apib.config.post_docs.map { |f| File.read(f) }.join("\n\n")
      end

      def sorted_apib
        @apib.to_a.sort { |a, b| a[0] <=> b[0] }
      end

      def build
        apib = ""

        sorted_apib.each do |group_name, group|
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
            apib += "#{data[:request][:description].indent(2, '  ')}\n\n" if data[:request][:description]
            apib += "    + Headers\n\n"
            data[:request][:headers].each do |header, value|
              apib += "            #{header}: #{value}\n"
            end
            apib += "\n"
            unless data[:request][:body].blank?
              apib += "    + Body\n\n"
              apib += extract_content(data[:request][:body]).indent(12)
              apib += "\n\n"
            end
            data[:response].sort { |a, b| a[:status] - b[:status] }.each do |response|
              apib += "+ Response #{response[:status]}\n\n"
              apib += "#{response[:description].indent(2, '  ')}\n\n" if response[:description]
              apib += "    + Headers\n\n"
              response[:headers].each do |header, value|
                apib += "            #{header}: #{value}\n"
              end
              apib += "\n"
              unless response[:body].to_s.scrub.blank?
                apib += "    + Body\n\n"
                apib += extract_content(response[:body]).indent(12)
                apib += "\n\n"
              end
            end
          end
        end

        apib
      end

      def extract_content(data = "")
        binary_content?(data) ? '[REDACTED BINARY CONTENT]' : data.to_s
      end

      def binary_content?(data)
        data.include?("content-disposition: form-data;") || data.bytes.any? { |byte| byte < 32 && byte != 9 && byte != 10 && byte != 13 }
      end
    end
  end
end
