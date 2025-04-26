# frozen_string_literal: true

require 'git'

# common parts for git finders
module Uncov::Finder::GitBase
  protected

  def relevant_file?(path)
    Uncov.configuration.relevant_files.any? do |pattern|
      File.fnmatch?(pattern, path, Uncov::Configuration::FILE_MATCH_FLAGS)
    end
  end

  def open_repo
    ::Git.open(Uncov.configuration.path)
  rescue ArgumentError => e
    raise Uncov::NotGitRepoError, Uncov.configuration.path if e.message.end_with?(' is not in a git working tree')

    raise
  end
end
