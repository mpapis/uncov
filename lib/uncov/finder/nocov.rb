# frozen_string_literal: true

# collect nocov information from files
class Uncov::Finder::Nocov
  def files(all_files)
    all_files.files.transform_values do |lines|
      nocov_lines(lines)
    end
  end

  private

  def nocov_lines(lines)
    nocov = false
    lines.filter_map do |number, line|
      line_nocov = line.strip.start_with?('# :nocov:')
      nocov = !nocov if line_nocov
      [number, true] if nocov || line_nocov # still true on disabling line
    end.to_h
  end
end
