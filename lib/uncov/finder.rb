# frozen_string_literal: true

# collects information about the files from different sources
class Uncov::Finder
  include Uncov::Cache

  def initialize(simplecov_trigger)
    @simplecov_trigger = simplecov_trigger
  end

  def build_line(file_name, line_number, context: false)
    Uncov::Report::File::Line.new(
      number: line_number,
      content: file_system_files.line(file_name, line_number),
      nocov: nocov_files.line(file_name, line_number),
      simplecov: simplecov_files.line(file_name, line_number),
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

  def nocov_files
    cache(:nocov_files) do
      Uncov::Finder::Files.new(Uncov::Finder::Nocov.new.files(file_system_files))
    end
  end

  def simplecov_files
    cache(:simplecov_files) do
      Uncov::Finder::Files.new(Uncov::Finder::Simplecov.files(simplecov_trigger_files))
    end
  end

  private

  attr_reader :simplecov_trigger

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

  def simplecov_trigger_files
    case simplecov_trigger
    when :git
      git_finder
    when :git_diff
      git_diff_finder
    when :file_system
      file_system_finder
    else
      # :nocov:
      raise Uncov::UnsupportedSimplecovTriggerError, simplecov_trigger
      # :nocov:
    end.simplecov_trigger_files
  end
end
