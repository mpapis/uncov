# frozen_string_literal: true

require_relative 'cache'
require_relative 'struct'

# calculated coverage report for configured report type
class Uncov::Report < Uncov::Struct.new(:files)
  include Uncov::Cache

  class << self
    def generate
      new(files: Uncov::Report::Filters.files)
    end
  end

  def display_files
    cache(:display_files) do
      files.select(&:display?)
    end
  end

  def coverage
    cache(:coverage) do
      if relevant_lines_count.zero?
        100.0
      else
        (covered_lines_count.to_f / relevant_lines_count * 100).round(2)
      end
    end
  end

  def relevant_lines_count = files.sum(&:relevant_lines_count)
  def covered_lines_count = files.sum(&:covered_lines_count)

  def trigger?
    cache(:trigger) do
      files.any?(&:trigger?)
    end
  end

  def display?
    display_files.any?
  end
end
