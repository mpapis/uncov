# frozen_string_literal: true

# collect nocov information from files
class Uncov::Finder::NoCov
  include Uncov::Cache

  def files(all_files)
    all_files.to_h do |file_name, lines|
      [file_name, nocov_lines(file_name, lines)]
    end
  end

  private

  def nocov_lines(file_name, lines)
    cache(file_name) do
      read_nocov(lines)
    end
  end

  def read_nocov(lines)
    nocov = false
    lines.filter_map do |number, line|
      line_nocov = line.strip.start_with?('# :nocov:')
      nocov = !nocov if line_nocov
      [number, true] if nocov || line_nocov # still true on disabling line
    end.to_h
  end
end
