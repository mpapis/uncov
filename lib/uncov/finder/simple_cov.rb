# frozen_string_literal: true

require 'json'

# collect coverage information, regenerates report if any trigger_files are newer then the report
module Uncov::Finder::SimpleCov
  class << self
    def files(trigger_files = [])
      regenerate_report if requires_regeneration?(trigger_files)
      raise MissingSimpleCovReport, coverage_path unless File.exist?(coverage_path)

      coverage.transform_values { |file_coverage| covered_lines(file_coverage) }
    end

    private

    def requires_regeneration?(trigger_files)
      return true unless File.exist?(coverage_path)
      return false if trigger_files.empty?

      coverage_path_mtime = File.mtime(coverage_path)
      trigger_files.any? { |file_name| File.exist?(file_name) && File.mtime(file_name) > coverage_path_mtime }
    end

    def regenerate_report = Dir.chdir(Uncov.configuration.path) { system(Uncov.configuration.test_command) }

    def coverage
      root_path = "#{File.absolute_path(Uncov.configuration.path)}/"
      parsed = JSON.parse(File.read(coverage_path))
      coverage = parsed['coverage'] || parsed.order_by { |suite| suite['timestamp'] }.last['coverage']
      coverage.transform_keys { |key| key.delete_prefix(root_path) }
    end

    def covered_lines(file_coverage)
      file_coverage['lines'].each_with_index.filter_map do |coverage, line_index|
        [line_index + 1, coverage.positive?] if coverage
      end.to_h
    end

    def coverage_path = File.join(Uncov.configuration.path, Uncov.configuration.simplecov_output_path)
  end
end
