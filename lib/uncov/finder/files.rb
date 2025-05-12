# frozen_string_literal: true

# wrap finder results to have the same interface as finder
class Uncov::Finder::Files
  attr_reader :files

  def initialize(files)
    @files = files
  end

  def file?(file_name)
    @files.key?(file_name)
  end

  def file_names
    @files.keys
  end

  def lines(file_name)
    @files[file_name]
  end

  def line(file_name, line_number)
    @files.dig(file_name, line_number)
  end

  def line?(file_name, line_number)
    lines(file_name)&.key?(line_number)
  end
end
