# frozen_string_literal: true

# collect files and their lines content from system
class Uncov::Finder::FileSystem
  include Uncov::Cache

  def files
    all_files.to_h do |file_name|
      [file_name, lines(file_name)]
    end
  end

  private

  def all_files
    Dir.glob(Uncov.configuration.relevant_files, Uncov::Configuration::FILE_MATCH_FLAGS).select { |f| File.file?(f) }
  end

  def lines(file_name)
    cache(file_name) do
      read_lines(file_name)
    end
  end

  def read_lines(file_name)
    File.readlines(file_name).each_with_index.to_h { |line, line_index| [line_index + 1, line.rstrip] }
  end
end
