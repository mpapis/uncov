# frozen_string_literal: true

require_relative '../report'

# generate report files and lines for the configured report type
module Uncov::Report::Generator
  class << self
    def types
      %w[diff_lines git_files]
    end

    def generate
      case Uncov.configuration.report
      when 'diff_lines'
        finder = Uncov::Finder.new(:git_diff)
        Uncov::Report::Generator::DiffLines.files(finder)
      when 'git_files'
        finder = Uncov::Finder.new(:git)
        Uncov::Report::Generator::GitFiles.files(finder)
      end
    end
  end
end
