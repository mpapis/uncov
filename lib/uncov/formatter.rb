# frozen_string_literal: true

# chose formater to output the report
module Uncov::Formatter
  class << self
    def output(report)
      case Uncov.configuration.output_format
      when :terminal
        Uncov::Formatter::Terminal.new(report).output
      else
        raise UnsupportedFormatterError, Uncov.configuration.output_format
      end
    end
  end
end
