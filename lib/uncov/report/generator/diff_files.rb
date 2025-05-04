# frozen_string_literal: true

# report only files lines from the diff
module Uncov::Report::Generator::DiffFiles
  Uncov::Report::Generator.register(self, :git_diff, 'Report missing coverage on added/changed files in the git diff')

  class << self
    def files(finder)
      finder.git_diff_file_names.map do |file_name|
        Uncov::Report::File.new(
          file_name:,
          git: true,
          lines: lines(finder, file_name)
        )
      end
    end

    private

    def lines(finder, file_name)
      lines_hash = file_lines(finder, file_name)
      add_context(lines_hash)
      lines_hash.sort.to_h.values
    end

    def file_lines(finder, file_name)
      finder.file_system_file_lines(file_name).to_h do |line_number, content|
        [line_number, new_line(finder, file_name, line_number, content)]
      end
    end

    def add_context(lines_hash)
      return if Uncov.configuration.context.zero?

      line_numbers =
        lines_hash.filter_map do |line_number, line|
          line_number if line.uncov?
        end
      all_line_numbers = lines_hash.keys
      context_line_numbers = Uncov::Report::Context.calculate(all_line_numbers, line_numbers, Uncov.configuration.context)
      context_line_numbers.each do |line_number|
        lines_hash[line_number].context = true
      end
    end

    def new_line(finder, file_name, line_number, content)
      Uncov::Report::File::Line.new(
        number: line_number,
        content:,
        no_cov: finder.no_cov_file_line?(file_name, line_number),
        simple_cov: finder.simple_cov_file_line?(file_name, line_number),
        git_diff: finder.git_diff_file_line?(file_name, line_number),
        context: false
      )
    end
  end
end
