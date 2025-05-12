# frozen_string_literal: true

require_relative 'formatter'
require_relative 'report/filters'

# handle configuration for uncov
class Uncov::Configuration
  CONFIG_FILE = '.uncov'
  # equivalent of `shopt -s extglob dotglob globstar` for testing with `bash` & `ls`
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
  option 'report', 'Report filter to generate file/line list',
         options: ['-r', '--report FILTER'], default: 'DiffLines', allowed_values: -> { Uncov::Report::Filters.filters.keys }
  option 'output_format', 'Output format',
         options: ['-o', '--output-format FORMAT'], default: 'Terminal', allowed_values: -> { Uncov::Formatter.formatters.keys }
  option 'context', 'Additional lines context in output',
         options: ['-C', '--context LINES_NUMBER'], default: 1, value_parse: lambda(&:to_i)
  option 'test_command', 'Test command that generates SimpleCov',
         options: '--test-command COMMAND', default: 'COVERAGE=true bundle exec rake test'
  option 'simplecov_file', 'SimpleCov results file', options: '--simplecov-file PATH', default: 'autodetect'
  option 'relevant_files', 'Only show uncov for matching code files AND trigger tests if matching code files are newer than the report',
         options: '--relevant-files FN_GLOB', default: '{{bin,exe,exec}/*,{app,lib}/**/*.{rake,rb},Rakefile}'
  option 'relevant_tests', 'Trigger tests if matching test files are newer than the report',
         options: '--relevant-tests FN_GLOB', default: '{test,spec}/**/*_{test,spec}.rb'
  option 'nocov_ignore', 'Ignore :nocov: markers - consider all lines',
         options: '--nocov-ignore', default: false, value_parse: ->(_value) { true }
  option 'nocov_covered', 'Report :nocov: lines that have coverage',
         options: '--nocov-covered', default: false, value_parse: ->(_value) { true }
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
    parser.on('-h', '--help', 'Print this help') do
      puts parser.help
      throw :exit, 0
    end
    footer_extras(parser)
  end

  def footer_extras(parser)
    # TODO: the release workflow does not like ' in help, please avoid it - or fix the workflow
    parser.separator <<~HELP

      Report FILTERs:
      #{footer_extras_types}

      Report FILTERs take NOTICE:
      git*/diff*  - filters will not consider new files unless added to the git index with `git add`.
      nocov*      - filters/flags only work with coverage/.resultset.json SimpleCov files,
                    coverage.json does not provide the information needed.

      FN_GLOB: shell filename globing -> https://ruby-doc.org/core-3.1.1/File.html#method-c-fnmatch
               in bash: `shopt -s extglob dotglob globstar` and test with `ls {app,lib}/**/*.rb`

      uncov #{Uncov::VERSION} by Michal Papis <mpapis@gmail.com>
    HELP
  end

  def footer_extras_types
    report_type_length = Uncov::Report::Filters.filters.keys.map(&:length).max
    Uncov::Report::Filters.filters.map do |name, filter|
      format("%#{report_type_length}s - %s", name, filter.description)
    end.join("\n")
  end

  def options
    @options ||= {}
  end
end
