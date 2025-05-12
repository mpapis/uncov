# frozen_string_literal: true

# represents file coverage in report
class Uncov::Report::File < Uncov::Struct.new(:file_name, :lines, :git)
  include Uncov::Cache

  def coverage
    cache(:coverage) do
      if relevant_lines_count.zero?
        100.0
      else
        (covered_lines_count.to_f / relevant_lines_count * 100).round(2)
      end
    end
  end

  def trigger?
    cache(:trigger) do
      lines.any?(&:trigger?)
    end
  end

  def display?
    display_lines.any?
  end

  def covered_lines_count
    cache(:covered_lines_count) do
      lines.count(&:covered?)
    end
  end

  def display_lines
    cache(:display_lines) do
      lines.select(&:display?)
    end
  end

  def relevant_lines_count
    cache(:relevant_lines_count) do
      lines.count(&:relevant?)
    end
  end
end
