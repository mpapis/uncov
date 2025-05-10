# frozen_string_literal: true

# represents file coverage in report
class Uncov::Report::File < Uncov::Struct.new(:file_name, :lines, :git)
  include Uncov::Cache

  def coverage
    cache(:coverage) do
      if relevant_lines.count.zero?
        100.0
      else
        (covered_lines.count.to_f / relevant_lines.count * 100).round(2)
      end
    end
  end

  def uncov?
    uncov_lines.any?
  end

  def uncov_lines
    cache(:uncov_lines) do
      lines.select(&:uncov?)
    end
  end

  def covered_lines
    cache(:covered_lines) do
      lines.select(&:covered?)
    end
  end

  def display_lines
    cache(:display_lines) do
      lines.select(&:display?)
    end
  end

  def relevant_lines
    cache(:relevant_lines) do
      lines.select(&:relevant?)
    end
  end
end
