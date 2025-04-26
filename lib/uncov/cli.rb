# frozen_string_literal: true

require 'optparse'

# provide terminal interface for uncov
class Uncov::CLI
  def self.start(args)
    new.start(args)
  end

  def start(args)
    parse_options(args)
    report = Uncov::Report.new
    Uncov::Formatter.output(report)
    exit(report.covered? ? 0 : 1)
  end

  private

  def parse_options(args) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    parser = OptionParser.new do |opts| # rubocop:disable Metrics/BlockLength
      opts.banner = 'Usage: uncov [options]'
      opts.on('-r', '--report TYPE', 'Report type to generate (git_diff)') do |type|
        Uncov.configuration.report = type.to_sym
      end
      opts.on('-t', '--target BRANCH', 'Target branch for comparison') do |branch|
        Uncov.configuration.git_diff_target = branch
      end
      opts.on('-c', '--command COMMAND', 'Test command to run SimpleCov') do |command|
        Uncov.configuration.test_command = command
      end
      opts.on('-p', '--path PATH', 'Target filesystem path') do |path|
        Uncov.configuration.path = path
      end
      opts.on('-f', '--formater FORMATTER', 'Formatter for output') do |formatter|
        Uncov.configuration.output_format = formatter.to_sym
      end
      opts.on('--simplecov-path PATH', 'Path to SimpleCov results') do |path|
        Uncov.configuration.simplecov_output_path = path
      end
      opts.on('-h', '--help', 'Print this help') do
        puts opts
        puts "uncov #{Uncov::VERSION} by Michal Papis <mpapis@gmail.com>"
        exit
      end
      opts.on('-v', '--version', 'Show version') do
        puts "uncov #{Uncov::VERSION} by Michal Papis <mpapis@gmail.com>"
        exit
      end
    end
    parser.parse!(args)
  end
end
