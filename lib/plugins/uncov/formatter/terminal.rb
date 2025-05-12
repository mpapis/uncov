# frozen_string_literal: true

require 'colorize'

# print report to terminal with colors
class Uncov::Formatter::Terminal
  include Uncov::Cache

  attr_reader :report

  def initialize(report)
    @report = report
  end

  def output
    return puts 'No files to report.'.green if report.files.empty?
    return puts "All changed files(#{report.files.count}) have 100% test coverage!".green unless report.trigger?

    output_header
    output_files
    output_summary
  end

  def output_header
    puts "Files with uncovered changes: (#{report.display_files.size} / #{report.files.count})".yellow
  end

  def output_files
    report.display_files.each do |file_coverage|
      output_file(file_coverage)
    end
  end

  def output_file(file_coverage)
    puts
    output_file_header(file_coverage)
    max = number_length(file_coverage)
    file_coverage.display_lines.each do |line|
      output_line(line, max)
    end
  end

  def output_file_header(file_coverage)
    puts format(
      '%<name>s -> %<coverage>.2f%% (%<covered_lines>d / %<relevant_lines>d) changes covered, uncovered lines:',
      name: file_coverage.file_name,
      coverage: file_coverage.coverage,
      covered_lines: file_coverage.covered_lines_count,
      relevant_lines: file_coverage.relevant_lines_count
    ).yellow
  end

  def output_line(line, max)
    if line.uncov?
      puts format_line(line, max).red
    elsif line.context
      puts format_line(line, max).green
    elsif line.nocov_covered?
      puts format_line(line, max).blue
    else
      # :nocov:
      raise 'unknown display line' # unreachable code
      # :nocov:
    end
  end

  def format_line(line, max)
    format("%#{max}d: %s", line.number, line.content)
  end

  def number_length(file_coverage)
    file_coverage.display_lines.last.number.to_s.length
  end

  def output_summary
    puts
    puts format(
      'Overall coverage of changes: %<coverage>.2f%% (%<covered_lines>d / %<relevant_lines>d)',
      coverage: report.coverage,
      covered_lines: report.covered_lines_count,
      relevant_lines: report.relevant_lines_count
    ).yellow
  end
end
