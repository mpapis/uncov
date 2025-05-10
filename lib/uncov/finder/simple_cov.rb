# frozen_string_literal: true

require 'json'

# collect coverage information, regenerates report if any trigger_files are newer then the report
module Uncov::Finder::SimpleCov
  class << self
    def files(trigger_files)
      regenerate_report if requires_regeneration?(trigger_files)
      raise_on_missing_coverage_path!
      coverage.transform_values do |file_coverage|
        covered_lines(file_coverage)
      end
    end

    private

    def requires_regeneration?(trigger_files)
      return true unless coverage_path
      return true unless File.exist?(coverage_path)
      return false if trigger_files.empty?

      coverage_path_mtime = File.mtime(coverage_path)
      changed_trigger_files =
        trigger_files.select do |file_name|
          File.exist?(file_name) && File.mtime(file_name) > coverage_path_mtime
        end
      warn("{changed_trigger_files: #{changed_trigger_files.inspect}}") if Uncov.configuration.debug
      changed_trigger_files.any?
    end

    def regenerate_report
      system(Uncov.configuration.test_command, exception: true)
    rescue RuntimeError
      raise Uncov::FailedToGenerateReport
    end

    def coverage
      root_path = "#{File.absolute_path('.')}/"
      parsed = JSON.parse(File.read(coverage_path))
      coverage = parsed['coverage'] || parsed.values.max_by { |suite| suite['timestamp'] }['coverage']
      coverage.transform_keys { |key| key.delete_prefix(root_path) }
    end

    def covered_lines(file_coverage)
      file_coverage['lines'].each_with_index.filter_map do |coverage, line_index|
        [line_index + 1, coverage.positive?] if coverage.is_a?(Integer)
      end.to_h
    end

    def coverage_path
      if Uncov.configuration.simplecov_file == 'autodetect'
        %w[coverage/coverage.json coverage/.resultset.json].find { |path| File.exist?(path) }
      else
        Uncov.configuration.simplecov_file
      end
    end

    def raise_on_missing_coverage_path!
      return if coverage_path && File.exist?(coverage_path)

      raise Uncov::AutodetectSimpleCovPathError if Uncov.configuration.simplecov_file == 'autodetect'

      raise Uncov::MissingSimpleCovReport, coverage_path
    end
  end
end
