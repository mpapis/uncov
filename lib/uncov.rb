# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/**/*.rb"]
  .sort_by { |f| f.count('/') }
  .each { |f| require f unless f.end_with?('lib/uncov.rb') }

# uncover missing code coverage by tests
module Uncov
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def reset
      self.configuration = Configuration.new
    end
  end

  class Error < StandardError; end
  class GitError < Error; end
  class SimpleCovError < Error; end
  class FormatterError < Error; end

  class NotGitRepoError < GitError
    attr_reader :path

    def initialize(path) = @path = path
    def message = "#{path.inspect} is not in a git working tree"
  end

  class NotGitBranchError < GitError
    attr_reader :target_branch

    def initialize(target_branch) = @target_branch = target_branch
    def message = "Target branch #{target_branch.inspect} not found locally or in remote"
  end

  class MissingSimpleCovReport < SimpleCovError
    attr_reader :coverage_path

    def initialize(coverage_path) = @coverage_path = coverage_path
    def message = "SimpleCov results not found at #{coverage_path.inspect}"
  end

  class UnsupportedFormatterError < FormatterError
    attr_reader :output_format

    def initialize(output_format) = @output_format = output_format
    def message = "#{output_format.inspect} is not a supported formatter"
  end
end

# Initialize with defaults
Uncov.configure
