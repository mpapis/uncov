# frozen_string_literal: true

require_relative 'cache'
require_relative 'struct'

# calculated coverage report for configured report type
class Uncov::Report < Uncov::Struct.new(:files)
  include Uncov::Cache

  class << self
    def types
      %w[diff_lines]
    end

    def build
      files =
        case Uncov.configuration.report
        when 'diff_lines'
          finder = Uncov::Finder.new(:git_diff)
          Uncov::Report::DiffLines.files(finder)
        end
      new(files:)
    end
  end

  def uncovered_files
    cache(:uncovered_files) do
      files.select(&:uncov?)
    end
  end

  def coverage
    cache(:coverage) do
      if files.empty?
        100.0
      else
        files.sum(&:coverage) / files.size
      end
    end
  end

  def uncov?
    uncovered_files.any?
  end
end
