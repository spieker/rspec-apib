module RSpec
  module Apib
    class CommentsParser
      attr_reader :example

      def initialize(example)
        @example = example
      end

      def full_comment
        line = example.metadata[:line_number]
        return if line.nil? || line <= 0

        lines = read_example_file
        return if lines.count < line

        i = line -2
        result = []

        while (i >= 0 && match = lines[i].match(/\A\s*#\s(.*)/)) do
          result.unshift(match[1])
          i -= 1
        end

        result
      end

      def description(namespace = nil)
        matcher = start_matcher(namespace)
        comment = full_comment()
        in_comment = false
        return nil if comment.blank?

        comment.select do |elem|
          if elem == matcher
            in_comment = true
          elsif elem.match?(/\A---($|[^-])/)
            in_comment = false
          end

          in_comment && elem != matcher
        end.join("\n")
      end

      private

      def read_example_file
        file = example.metadata[:absolute_file_path]
        return [] if file.nil? || file.empty?
        return [] unless File.exists?(file)
        IO.readlines(file)
      end

      def start_matcher(namespace)
        return "--- apib" if namespace.blank?
        "--- apib:#{namespace}"
      end
    end
  end
end
