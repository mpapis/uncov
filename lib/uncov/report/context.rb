# frozen_string_literal: true

# calculate context for important lines,
# @return [Integer] only added context lines matching all_line_numbers and not in important_line_numbers
module Uncov::Report::Context
  class << self
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
  end
end
