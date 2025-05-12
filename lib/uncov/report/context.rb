# frozen_string_literal: true

# calculate context for important lines,
# @return [Integer] only added context lines matching all_line_numbers and not in important_line_numbers
module Uncov::Report::Context
  class << self
    def add_context(finder, file_name, lines_hash)
      return if Uncov.configuration.context.zero?

      line_numbers =
        lines_hash.filter_map do |line_number, line|
          line_number if line.trigger?
        end
      all_line_numbers = finder.file_system_files.lines(file_name).keys
      context_line_numbers = calculate(all_line_numbers, line_numbers, Uncov.configuration.context)
      context_line_numbers.each do |line_number|
        mark_context_line(finder, file_name, lines_hash, line_number)
      end
    end

    def calculate(all_line_numbers, important_line_number, context)
      context_line_numbers = {}
      important_line_number.each do |line_number|
        (1..context).to_a.each do |offset|
          context_line_numbers[line_number - offset] = true
          context_line_numbers[line_number + offset] = true
        end
      end
      (context_line_numbers.keys.sort & all_line_numbers) - important_line_number
    end

    private

    def mark_context_line(finder, file_name, lines_hash, line_number)
      if lines_hash.key?(line_number)
        lines_hash[line_number].context = true
      else
        lines_hash[line_number] = finder.build_line(file_name, line_number, context: true)
      end
    end
  end
end
