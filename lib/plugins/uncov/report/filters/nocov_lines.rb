# frozen_string_literal: true

# report only files lines from the diff
module Uncov::Report::Filters::NocovLines
  class << self
    def description = 'Report coverage on nocov lines, requires one or both: --nocov-ignore / --nocov-covered'
    def simple_cov_trigger = :file_system

    def files(finder)
      finder.no_cov_files.file_names.filter_map do |file_name|
        next if finder.no_cov_files.lines(file_name).empty?

        Uncov::Report::File.new(
          file_name:,
          git: finder.git_files.file?(file_name),
          lines: lines(finder, file_name)
        )
      end
    end

    private

    def lines(finder, file_name)
      lines_hash = nocov_files_lines(finder, file_name)
      Uncov::Report::Context.add_context(finder, file_name, lines_hash)
      lines_hash.sort.to_h.values
    end

    def nocov_files_lines(finder, file_name)
      finder.no_cov_files.lines(file_name).keys.to_h do |line_number|
        [line_number, finder.build_line(file_name, line_number)]
      end
    end
  end
end
