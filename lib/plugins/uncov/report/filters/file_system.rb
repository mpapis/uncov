# frozen_string_literal: true

# report all files lines from the file system
module Uncov::Report::Filters::FileSystem
  class << self
    def description = 'Report missing coverage on file system'
    def simplecov_trigger = :file_system

    def files(finder)
      finder.file_system_files.file_names.map do |file_name|
        Uncov::Report::File.new(
          file_name:,
          git: finder.git_files.file?(file_name),
          lines: lines(finder, file_name)
        )
      end
    end

    private

    def lines(finder, file_name)
      lines_hash = file_lines(finder, file_name)
      Uncov::Report::Context.add_context(finder, file_name, lines_hash)
      lines_hash.sort.to_h.values
    end

    def file_lines(finder, file_name)
      finder.file_system_files.lines(file_name).keys.to_h do |line_number|
        [line_number, finder.build_line(file_name, line_number)]
      end
    end
  end
end
