# frozen_string_literal: true

# collects information about the files from different sources
class Uncov::Finder
  include Uncov::Cache

  def initialize(simple_cov_trigger)
    @simple_cov_trigger = simple_cov_trigger
  end

  def build_line(file_name, line_number, context: false)
    Uncov::Report::File::Line.new(
      number: line_number,
      content: file_system_files.line(file_name, line_number),
      no_cov: no_cov_files.line(file_name, line_number),
      simple_cov: simple_cov_files.line(file_name, line_number),
      git_diff: git_diff_files.line?(file_name, line_number),
      context:
    )
  end

  def file_system_files
    Uncov::Finder::Files.new(file_system_finder.code_files)
  end

  def git_files
    Uncov::Finder::Files.new(git_finder.code_files)
  end

  def git_diff_files
    Uncov::Finder::Files.new(git_diff_finder.code_files)
  end

  def no_cov_files
    cache(:no_cov_files) do
      Uncov::Finder::Files.new(Uncov::Finder::NoCov.new.files(file_system_files))
    end
  end

  def simple_cov_files
    cache(:simple_cov_files) do
      Uncov::Finder::Files.new(Uncov::Finder::SimpleCov.files(simple_cov_trigger_files))
    end
  end

  private

  attr_reader :simple_cov_trigger

  def file_system_finder
    cache(:file_system_finder) do
      Uncov::Finder::FileSystem.new
    end
  end

  def git_finder
    cache(:git_finder) do
      Uncov::Finder::Git.new
    end
  end

  def git_diff_finder
    cache(:git_diff_finder) do
      Uncov::Finder::GitDiff.new
    end
  end

  def simple_cov_trigger_files
    case simple_cov_trigger
    when :git
      git_finder
    when :git_diff
      git_diff_finder
    when :file_system
      file_system_finder
    else
      # :nocov:
      raise Uncov::UnsupportedSimpleCovTriggerError, simple_cov_trigger
      # :nocov:
    end.simple_cov_trigger_files
  end
end
