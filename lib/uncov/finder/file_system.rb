# frozen_string_literal: true

# collect files and their lines content from system
class Uncov::Finder::FileSystem
  include Uncov::Cache

  def code_files
    cache(:code_files) do
      list_files(Uncov.configuration.relevant_files).to_h do |file_name|
        [file_name, read_lines(file_name)]
      end
    end
  end

  def simplecov_trigger_files
    code_files.keys + test_files
  end

  private

  def test_files
    cache(:test_files) do
      list_files(Uncov.configuration.relevant_tests)
    end
  end

  def list_files(glob)
    Dir.glob(glob, Uncov::Configuration::FILE_MATCH_FLAGS).select { |f| File.file?(f) }
  end

  def read_lines(file_name)
    lines = {}
    File.foreach(file_name).with_index(1) { |line, idx| lines[idx] = line.chomp }
    lines
  end
end
