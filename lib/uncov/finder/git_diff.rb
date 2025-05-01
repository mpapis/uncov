# frozen_string_literal: true

require_relative 'git_base'
require 'git_diff_parser'

# collect list of changed files and their added lines (removed do not impact coverage)
module Uncov::Finder::GitDiff
  class << self
    include Uncov::Finder::GitBase

    def files
      git_diff.filter_map do |file_diff|
        [file_diff.path, changed_lines(file_diff)] if relevant_file?(file_diff.path)
      end.to_h
    end

    private

    def changed_lines(file_diff)
      GitDiffParser.parse(file_diff.patch).flat_map do |patch|
        patch.changed_lines.map do |changed_line|
          [changed_line.number, nil] if changed_line.content[0] == '+'
        end
      end.compact.to_h
    end

    def git_diff
      repo = open_repo
      target =
        case git_diff_target
        when 'HEAD'
          git_diff_target
        else
          repo.branches[git_diff_target] or raise Uncov::NotGitBranchError, git_diff_target
        end

      repo.diff(target)
    end

    def git_diff_target = Uncov.configuration.git_diff_target
  end
end
