# frozen_string_literal: true

# collects information about the files from different sources
class Uncov::Finder
  include Uncov::Cache

  def initialize(simple_cov_trigger) = @simple_cov_trigger = simple_cov_trigger
  def git_file?(file_name) = git_files[file_name]
  def git_file_names = git_files.keys
  def git_diff_file_names = git_diff_files.keys
  def git_diff_file_lines(file_name) = git_diff_files[file_name]
  def git_diff_file_line?(file_name, line_number) = git_diff_files[file_name]&.key?(line_number)
  def file_system_file_names = file_system_files.keys
  def file_system_file_line(file_name, line_number) = file_system_files[file_name]&.dig(line_number)
  def file_system_file_lines(file_name) = file_system_files[file_name]
  def no_cov_file_names = no_cov_files.keys
  def no_cov_file_lines(file_name) = no_cov_files[file_name]
  def no_cov_file_line?(file_name, line_number) = no_cov_files[file_name]&.dig(line_number)
  def simple_cov_file_line?(file_name, line_number) = simple_cov_files.dig(file_name, line_number)

  def debug
    {
      git_files:,
      git_test_files:,
      git_diff_files:,
      git_diff_test_files:,
      file_system_files:,
      no_cov_files:,
      simple_cov_files:
    }
  end

  private

  attr_reader :simple_cov_trigger

  def git_files
    git_finder.code_files
  end

  def git_test_files
    git_finder.test_files
  end

  def git_finder
    cache(:git_finder) do
      Uncov::Finder::Git.new
    end
  end

  def git_diff_files
    git_diff_finder.code_files
  end

  def git_diff_test_files
    git_diff_finder.test_files
  end

  def git_diff_finder
    cache(:git_diff_finder) do
      Uncov::Finder::GitDiff.new
    end
  end

  def file_system_files
    cache(:file_system_files) do
      Uncov::Finder::FileSystem.new.files
    end
  end

  def no_cov_files
    cache(:no_cov_files) do
      Uncov::Finder::NoCov.new.files(file_system_files)
    end
  end

  def simple_cov_files
    cache(:simple_cov_files) do
      Uncov::Finder::SimpleCov.files(simple_cov_trigger_files)
    end
  end

  def simple_cov_trigger_files
    case simple_cov_trigger
    when :git
      git_file_names + git_test_files.keys
    when :git_diff
      git_diff_file_names + git_diff_test_files.keys
    when :file_system
      file_system_file_names
    else
      # :nocov:
      raise Uncov::UnsupportedSimpleCovTriggerError, simple_cov_trigger
      # :nocov:
    end
  end
end
