# frozen_string_literal: true

require 'git'

# common parts for git finders
module Uncov::Finder::GitBase
  protected

  def relevant_code_file?(path)
    File.fnmatch?(Uncov.configuration.relevant_files, path, Uncov::Configuration::FILE_MATCH_FLAGS)
  end

  def relevant_test_file?(path)
    File.fnmatch?(Uncov.configuration.relevant_tests, path, Uncov::Configuration::FILE_MATCH_FLAGS)
  end

  def open_repo
    ::Git.open('.')
  rescue ArgumentError => e
    raise Uncov::NotGitRepoError, Uncov.configuration.path if e.message.end_with?(' is not in a git working tree')

    raise
  end
end
