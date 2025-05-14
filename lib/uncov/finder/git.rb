# frozen_string_literal: true

require_relative 'git_base'

# collect list of files stored in git
class Uncov::Finder::Git
  include Uncov::Finder::GitBase

  def code_files
    cache(:code_files) do
      all_file_names.filter_map do |file_name|
        [file_name, true] if relevant_code_file?(file_name)
      end.to_h
    end
  end

  def simplecov_trigger_files
    code_files.keys + test_files
  end

  private

  def test_files
    cache(:test_files) do
      all_file_names.select do |file_name|
        relevant_test_file?(file_name)
      end
    end
  end

  def all_file_names
    cache(:all_files) do
      open_repo.ls_files.keys
    end
  end
end
