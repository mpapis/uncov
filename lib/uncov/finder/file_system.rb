# frozen_string_literal: true

# collect files and their lines content from system
class Uncov::Finder::FileSystem
  include Uncov::Cache

  def code_files
    list_files(Uncov.configuration.relevant_files).to_h do |file_name|
      [file_name, read_lines(file_name)]
    end
  end

  def simple_cov_trigger_files
    code_files.keys + test_files
  end

  private

  def test_files
    list_files(Uncov.configuration.relevant_tests)
  end

  def list_files(glob)
    Dir.glob(glob, Uncov::Configuration::FILE_MATCH_FLAGS).select { |f| File.file?(f) }
  end

  def read_lines(file_name)
    File.readlines(file_name).each_with_index.to_h { |line, line_index| [line_index + 1, line.rstrip] }
  end
end
