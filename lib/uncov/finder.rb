# frozen_string_literal: true

# collects information about the files from different sources
class Uncov::Finder
  include Uncov::Cache

  def initialize(simple_cov_trigger) = @simple_cov_trigger = simple_cov_trigger
  def git_file?(file_name) = git_files[file_name]
  def git_file_names = git_files.keys
  def git_diff_file_names = git_diff_files.keys
  def git_diff_file_line?(file_name, line_number) = git_diff_files[file_name].key?(line_number)
  def git_diff_file_lines(file_name) = git_diff_files[file_name]
  def file_system_file_line(file_name, line_number) = file_system_files[file_name]&.call&.dig(line_number)
  def file_system_file_lines(file_name) = file_system_files[file_name]&.call
  def no_cov_file_line?(file_name, line_number) = no_cov_files[file_name]&.call&.dig(line_number)
  def simple_cov_file_line?(file_name, line_number) = simple_cov_files.dig(file_name, line_number)

  def debug
    {
      git_files:,
      git_diff_files:,
      file_system_files: file_system_files.transform_values(&:call),
      no_cov_files: no_cov_files.transform_values(&:call),
      simple_cov_files:
    }
  end

  private

  attr_reader :simple_cov_trigger

  def git_files = cache(:git_files) { Uncov::Finder::Git.files }
  def git_diff_files = cache(:git_diff_files) { Uncov::Finder::GitDiff.files }
  def file_system_files = cache(:file_system_files) { Uncov::Finder::FileSystem.new.files }
  def no_cov_files = cache(:no_cov_files) { Uncov::Finder::NoCov.new.files(file_system_files) }
  def simple_cov_files = cache(:simple_cov_files) { Uncov::Finder::SimpleCov.files(simple_cov_trigger_files) }

  def simple_cov_trigger_files
    case simple_cov_trigger
    when :git
      git_file_names
    when :git_diff
      git_diff_file_names
    end
  end
end
