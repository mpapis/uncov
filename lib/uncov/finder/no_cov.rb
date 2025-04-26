# frozen_string_literal: true

# collect nocov information from files
class Uncov::Finder::NoCov
  include Uncov::Cache

  def files(all_files)
    all_files.to_h { |file_name, lines| [file_name, nocov_proc(file_name, lines)] }
  end

  private

  def nocov_proc(file_name, lines_proc) = -> { cache(file_name) { read_nocov(lines_proc) } }

  def read_nocov(lines_proc)
    nocov = false
    lines_proc.call.filter_map do |number, line|
      line_nocov = line.strip.start_with?('# :nocov:')
      nocov = !nocov if line_nocov
      [number, true] if nocov || line_nocov # still true on disabling line
    end.to_h
  end
end
