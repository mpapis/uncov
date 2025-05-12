# frozen_string_literal: true

# chose formater to output the report
module Uncov::Formatter
  class << self
    def formats = %w[terminal]

    def output(report)
      if report.files.empty?
        return puts 'No files to report.'.green
      elsif !report.trigger?
        return puts "All changed files(#{report.files.count}) have 100% test coverage!".green
      end

      output_report(report)
    end

    private

    def output_report(report)
      case Uncov.configuration.output_format
      when 'terminal'
        Uncov::Formatter::Terminal.new(report).output
      else
        raise Uncov::UnsupportedFormatterError, Uncov.configuration.output_format
      end
    end
  end
end
