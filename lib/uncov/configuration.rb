# frozen_string_literal: true

require_relative 'formatter'
require_relative 'report'

# handle configuration for uncov
class Uncov::Configuration
  CONFIG_FILE = '.uncov'
  FILE_MATCH_FLAGS = File::FNM_EXTGLOB | File::FNM_PATHNAME | File::FNM_DOTMATCH

  class << self
    def option(name, description, options:, default:, allowed_values: nil, value_parse: ->(value) { value })
      self.options << [name, description, options, default, allowed_values, value_parse]
      define_method(name) { self.options[name].value }
      define_method("#{name}=") { |value| self.options[name].value = value }
    end

    def options = @options ||= []
  end

  option 'target', 'Target branch for comparison', options: ['-t', '--target TARGET'], default: 'HEAD'
  option 'report', 'Report type to generate', options: ['-r', '--report TYPE'], default: 'diff_lines', allowed_values: Uncov::Report.types
  option 'output_format', 'Output format',
         options: ['-o', '--output-format FORMAT'], default: 'terminal', allowed_values: Uncov::Formatter.formats
  option 'context', 'Additional lines context in output',
         options: ['-C', '--context LINES_NUMBER'], default: 1, value_parse: lambda(&:to_i)
  option 'test_command', 'Test command that generates SimpleCov',
         options: '--test-command COMMAND', default: 'COVERAGE=true bundle exec rake test'
  option 'simplecov_file', 'SimpleCov results file', options: '--simplecov-file PATH', default: 'autodetect'
  option 'relevant_files', 'Relevant files shell filename globing: https://ruby-doc.org/core-3.1.1/File.html#method-c-fnmatch',
         options: '--relevant-files', default: '{{bin,exe,exec}/*,{app,lib}/**/*.{rake,rb},Rakefile}'
  option 'debug', 'Get some insights', options: '--debug', default: false, value_parse: ->(_value) { true }

  def initialize
    define_options
    parse_config
  end

  def parse_cli(args) = parser.parse!(args)
  def options_values = options.to_h { |name, option| [name.to_sym, option.value] }

  private

  def define_options
    self.class.options.each do |name, description, options, default, allowed_values, value_parse|
      self.options[name] = Option.new(name, description, options, default, allowed_values, value_parse)
    end
  end

  def parse_config
    return unless File.exist?(CONFIG_FILE)

    args = File.readlines(CONFIG_FILE).map(&:strip)
    parse_cli(args)
  end

  def parser
    @parser ||=
      OptionParser.new do |parser|
        parser_header(parser)
        options.each_value { |option| option.on_parser(parser) }
        parser_footer(parser)
      end
  end

  def parser_header(parser) = parser.banner = 'Usage: uncov [options]'

  def parser_footer(parser)
    parser.on('-v', '--version', 'Show version') do
      puts "uncov #{Uncov::VERSION} by Michal Papis <mpapis@gmail.com>"
      throw :exit, 0
    end
    parser.on('-h', '--help', 'Print this help') do
      puts parser
      puts "uncov #{Uncov::VERSION} by Michal Papis <mpapis@gmail.com>"
      throw :exit, 0
    end
  end

  def options = @options ||= {}
end
