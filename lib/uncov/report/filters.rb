# frozen_string_literal: true

require 'pluginator'
require_relative '../report'

# generate report files and lines for the configured report type
module Uncov::Report::Filters
  class << self
    def filters
      @filters ||= Uncov.plugins.plugins_map('report/filters')
    end

    def files
      raise Uncov::UnsupportedReportTypeError, Uncov.configuration.report unless filters.key?(Uncov.configuration.report)

      filter = filters[Uncov.configuration.report]
      filter.files(Uncov::Finder.new(filter.simplecov_trigger))
    end
  end
end
