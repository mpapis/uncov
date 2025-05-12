# frozen_string_literal: true

require_relative '../report'

# generate report files and lines for the configured report type
module Uncov::Report::Generator
  class << self
    def filters
      @filters ||= {}
    end

    def register(generator_class, simple_cov_trigger, description)
      class_name = generator_class.to_s.split('::').last
      generator_name = class_name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
      filters[generator_name] = { generator_class:, simple_cov_trigger:, description: }
    end

    def generate
      raise Uncov::UnsupportedReportTypeError, Uncov.configuration.report unless filters.key?(Uncov.configuration.report)

      filters[Uncov.configuration.report] => { generator_class:, simple_cov_trigger: }
      generator_class.files(Uncov::Finder.new(simple_cov_trigger))
    end
  end
end
