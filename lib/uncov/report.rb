# frozen_string_literal: true

require_relative 'cache'
require_relative 'struct'

# calculated coverage report for configured report type
class Uncov::Report < Uncov::Struct.new(:files)
  include Uncov::Cache

  class << self
    def generate
      new(files: Uncov::Report::Generator.generate)
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
        (files.sum(&:coverage) / files.size).round(2)
      end
    end
  end

  def uncov?
    uncovered_files.any?
  end
end
