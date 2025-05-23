# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/**/*.rb"]
  .sort_by { |f| f.count('/') }
  .each { |f| require f unless f.end_with?('lib/uncov.rb') }

# uncover missing code coverage by tests
module Uncov
  class << self
    def configure(args = [])
      yield(configuration) if block_given?
      configuration.parse_cli(args) if args.any?
      warn("{configuration: #{configuration.options_values.inspect}}") if configuration.debug
      nil
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configuration_reset!
      @configuration = Configuration.new
    end

    def plugins
      @plugins ||= Pluginator.find('uncov', extends: ['plugins_map'])
    end
  end

  class Error < StandardError
    def inspect = "#<#{self.class}: #{message}>"
  end

  class ConfigurationError < Error; end
  class GitError < Error; end
  class FinderError < Error; end
  class SimplecovError < FinderError; end
  class FormatterError < Error; end
  class ReportError < Error; end
  class OptionValueNotAllowed < ConfigurationError; end

  class NotGitRepoError < GitError
    attr_reader :path

    def initialize(path) = @path = path
    def message = "#{path.inspect} is not in a git working tree"
  end

  class NotGitObjectError < GitError
    attr_reader :target_branch

    def initialize(target_branch) = @target_branch = target_branch
    def message = "Git target #{target_branch.inspect} not found locally"
  end

  class UnsupportedSimplecovTriggerError < FinderError
    attr_reader :trigger

    def initialize(trigger) = @trigger = trigger
    def message = "#{trigger.inspect} is not a supported simplecov_trigger type"
  end

  class FailedToGenerateReport < SimplecovError
    def message = cause.message
  end

  class MissingSimplecovReport < SimplecovError
    attr_reader :coverage_path

    def initialize(coverage_path) = @coverage_path = coverage_path
    def message = "SimpleCov results not found at #{coverage_path.inspect}"
  end

  class AutodetectSimplecovPathError < SimplecovError
    def message = 'Could not autodetect coverage report path'
  end

  class UnsupportedFormatterError < FormatterError
    attr_reader :output_format

    def initialize(output_format) = @output_format = output_format
    def message = "#{output_format.inspect} is not a supported formatter"
  end

  class UnsupportedReportTypeError < ReportError
    attr_reader :type

    def initialize(type) = @type = type
    def message = "#{type.inspect} is not a supported report type"
  end
end
