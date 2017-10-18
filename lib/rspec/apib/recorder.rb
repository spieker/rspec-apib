module RSpec
  module Apib
    class Recorder
      attr_reader :example, :request, :response, :routes, :apib

      def initialize(example, request, response, routes, apib)
        @example  = example
        @request  = request
        @response = response
        @routes   = routes
        @apib     = apib
      end

      def run
        return unless request
        return unless response

        document_request
        document_response
      end

      private

      # Request headers contained in the blacklist will not be included in the
      # API documentation
      def request_header_blacklist
        RSpec::Apib.config.request_header_blacklist
      end

      def request_param_blacklist
        RSpec::Apib.config.request_param_blacklist
      end

      # The routing object for the rails route of the request
      def route
        return @route if @route
        routes.router.recognize(request) do |r, params|
          @route = r
        end
        @route
      end

      # The top level example group the example is contained in
      def example_group
        @example_group ||= begin
          example_group = example.metadata[:example_group]
          while example_group[:parent_example_group]
            example_group = example_group[:parent_example_group]
          end
          example_group
        end
      end

      def path
        @path ||= begin
          parts = route.parts
          tmp = {}
          parts.each do |part|
            optional_parts = route.respond_to?(:optional_parts) ?
                               route.optional_parts :
                               (route.parts - route.required_parts)

            if optional_parts.include?(part)
              tmp[part] = "(:#{part}:)"
            else
              tmp[part] = ":#{part}:"
            end
          end
          result = route.format(tmp).gsub(/:(.*?):/, '{\\1}')
          result = result.gsub('.(', '(.')
          result = result.gsub('/(', '(/')
          result
        end
      end

      def group
        @group ||= begin
          apib[resource_name] ||= {}
        end
      end

      def resource_type
        @resource_type ||= begin
          route.required_parts.include?(:id) ? 'resource' : 'collection'
        end
      end

      def resource_name
        @resource_name ||= example_group[:description].to_s.singularize
      end

      def action
        @action ||= begin
          name = "#{request.method} #{path}"
          group[name] ||= {
            request: { _status: 600 },
            response: []
          }
        end
      end

      def document_request
        document_request_params
        return if response.status >= action[:request][:_status]
        action[:request][:_status] = response.status
        action[:request][:path]    = request.path
        action[:request][:body]    = request.body.read
        document_request_header
      end

      def document_request_header
        action[:request][:headers] = {}
        request.headers.each do |k, v|
          next unless k.starts_with?('HTTP_')
          header = k.gsub('HTTP_', '').downcase
          next if request_header_blacklist.include? header
          next if v.nil? || v.empty?
          action[:request][:headers][header] = v
        end
      end

      def document_request_params
        return if (200..299).exclude?(response.status)
        params = request.params.symbolize_keys
        request_param_blacklist.each { |param| params.except!(param) }
        action[:request][:params] ||= {}
        params.each do |name, value|
          action[:request][:params][name] ||= {
            value: value,
            path: route.parts.include?(name),
            required: route.required_parts.include?(name)
          }
        end
      end

      def document_response
        data = {}
        return if response_exists?
        data[:description]  = document_extended_description || example.description
        data[:status]       = response.status
        data[:content_type] = response.content_type.to_s
        data[:body]         = response.body
        data[:headers]      = response.headers
        action[:response] << data
      end

      def document_extended_description
        file = example.metadata[:absolute_file_path]
        line = example.metadata[:line_number]
        return if file.nil? || file.empty?
        return if line.nil? || line <= 0
        return unless File.exists?(file)
        lines = IO.readlines(file)
        return if lines.count < line
        i = line -2
        m = false
        while (i >= 0 && lines[i].match(/\A\W*#/)) do
          if lines[i - 1].match(/\A\W*# --- apib/)
            m = true
            break
          end
          i -= 1
        end
        return unless m
        result = []
        while (i < line && lines[i].match(/\A\W*#/)) do
          if lines[i].match(/\A\W*# ---/)
            break
          end
          result << lines[i].sub(/^\W*#\W*/, '').strip
          i += 1
        end
        return result.join("\n")
      end

      def response_exists?
        action[:response].any? { |r| r[:status] == response.status }
      end
    end
  end
end
