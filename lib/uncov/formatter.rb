# frozen_string_literal: true

# chose formater to output the report
module Uncov::Formatter
  class << self
    def formatters
      @formatters ||= Uncov.plugins.plugins_map('formatter')
    end

    def output(report)
      raise Uncov::UnsupportedFormatterError, Uncov.configuration.output_format unless formatters.key?(Uncov.configuration.output_format)

      formatters[Uncov.configuration.output_format].new(report).output
    end
  end
end
