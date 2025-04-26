# frozen_string_literal: true

# report only files lines from the diff
module Uncov::Report::DiffLines
  class << self
    def files(report)
      report.git_diff_file_names.map do |file_name|
        Uncov::Report::File.new(
          file_name:,
          git: true,
          lines: lines(report, file_name)
        )
      end
    end

    private

    def lines(report, file_name)
      report.git_diff_file_lines(file_name).keys.map do |line_number|
        Uncov::Report::File::Line.new(
          number: line_number,
          content: report.file_system_file_line(file_name, line_number),
          no_cov: report.no_cov_file_line?(file_name, line_number),
          simple_cov: report.simple_cov_file_line?(file_name, line_number),
          git_diff: true
        )
      end
    end
  end
end
