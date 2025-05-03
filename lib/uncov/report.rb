# frozen_string_literal: true

require_relative 'cache'

# calculated coverage report for configured report type
class Uncov::Report
  include Uncov::Cache

  def self.types = %w[diff_lines]

  def files
    cache(:files) do
      case Uncov.configuration.report
      when 'diff_lines'
        finder = Uncov::Finder.new(:git_diff)
        Uncov::Report::DiffLines.files(finder)
      end
    end
  end

  def uncovered_files = cache(:uncovered_files) { files.reject(&:covered?) }
  def coverage = cache(:coverage) { files.sum(&:coverage) / files.size }
  def covered? = files.all?(&:covered?)
end
