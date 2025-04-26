# frozen_string_literal: true

require 'colorize'
require 'forwardable'

# print report to terminal with colors
class Uncov::Formatter::Terminal
  attr_reader :report

  def initialize(report)
    @report = report
  end

  def output
    if report.covered?
      puts 'All changed files have 100% test coverage!'.green
      return
    end

    puts "Found #{report.uncovered_files.size} files with uncovered changes:".yellow
    output_files
    puts format("\nOverall coverage of changes: %.2f%%", report.coverage).yellow
  end

  def output_files = report.uncovered_files.each { |file_coverage| output_file(file_coverage) }

  def output_file(file_coverage)
    puts format(
      "\n%<name>s -> %<coverage>.2f%% changes covered, uncovered lines:",
      name: file_coverage.file_name,
      coverage: file_coverage.coverage
    ).yellow
    nl = number_length(file_coverage)
    file_coverage.uncovered_lines.each do |line|
      puts format("%#{nl}d: %s", line.number, line.content).red
    end
  end

  def number_length(file_coverage) = file_coverage.uncovered_lines.last.number.to_s.length
end
