# frozen_string_literal: true

# collect files and their lines content from system
class Uncov::Finder::FileSystem
  include Uncov::Cache

  def files = all_files.to_h { |file_name| [file_name, lines_proc(file_name)] }

  private

  def all_files
    Uncov.configuration.relevant_files.flat_map do |expresion|
      Dir
        .glob(expresion, Uncov::Configuration::FILE_MATCH_FLAGS, base: Uncov.configuration.path)
        .select { |f| File.file?(f) }
    end
  end

  def lines_proc(file_name) = -> { cache(file_name) { read_lines(file_name) } }

  def read_lines(file_name)
    File.readlines(file_name).each_with_index.to_h { |line, line_index| [line_index + 1, line.rstrip] }
  end
end
