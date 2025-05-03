# frozen_string_literal: true

require 'optparse'

# provide terminal interface for uncov
class Uncov::CLI
  def self.start(args)
    Uncov.configure(args)
    report = Uncov::Report.new
    Uncov::Formatter.output(report)
    report.covered?
  rescue StandardError => e
    raise if Uncov.configuration.debug

    warn e.message
    nil
  end
end
