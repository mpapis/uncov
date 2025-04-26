# frozen_string_literal: true

# represents file coverage in report
class Uncov::Report::File
  include Uncov::Cache

  attr_reader :file_name, :lines, :git

  def initialize(file_name:, lines:, git:)
    @file_name = file_name
    @lines = lines
    @git = git
  end

  def coverage
    cache(:coverage) do
      if relevant_lines.count.zero?
        100.0
      else
        (covered_lines.count.to_f / relevant_lines.count * 100).round(2)
      end
    end
  end

  def covered? = lines.all?(&:covered?)
  def changed_lines = lines.select(&:git_diff)
  def covered_lines = lines.select(&:covered?)
  def uncovered_lines = lines.reject(&:covered?)
  def relevant_lines = lines.select(&:relevant?)
end
