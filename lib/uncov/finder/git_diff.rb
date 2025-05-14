# frozen_string_literal: true

require_relative 'git_base'
require 'git_diff_parser'

# collect list of changed files and their added lines (removed do not impact coverage)
class Uncov::Finder::GitDiff
  include Uncov::Finder::GitBase

  def code_files
    cache(:code_files) do
      all_files_diff.filter_map do |file_diff|
        [file_diff.path, changed_lines(file_diff)] if relevant_code_file?(file_diff.path) && File.exist?(file_diff.path)
      end.to_h
    end
  end

  def simplecov_trigger_files
    code_files.keys + test_files
  end

  private

  def test_files
    cache(:test_files) do
      all_files_diff.filter_map do |file_diff|
        file_diff.path if relevant_test_file?(file_diff.path) && File.exist?(file_diff.path)
      end
    end
  end

  def all_files_diff
    cache(:all_files) do
      git_diff
    end
  end

  def changed_lines(file_diff)
    GitDiffParser.parse(file_diff.patch).flat_map do |patch|
      patch.changed_lines.map do |changed_line|
        next unless changed_line.content[0] == '+'

        [changed_line.number, nil]
      end
    end.compact.to_h
  end

  def git_diff
    repo = open_repo
    # TODO: resolve the need for verifying the target with git gem
    git_target = repo.lib.send(:command, 'rev-parse', '--verify', target)
    repo.diff(git_target)
  rescue Git::FailedError => e
    raise Uncov::NotGitObjectError, target if e.result.status.exitstatus == 128 && e.result.stderr.include?('fatal: Needed a single revision')

    # :nocov: when we find a failing example, we can test it
    raise
    # :nocov:
  end

  def target
    Uncov.configuration.target
  end
end
