# frozen_string_literal: true

require 'optparse'

# provide terminal interface for uncov
class Uncov::CLI
  def self.start(args)
    Uncov.configure(args)
    report = Uncov::Report.generate
    Uncov::Formatter.output(report)
    !report.trigger?
  rescue StandardError => e
    raise if Uncov.configuration.debug

    warn e.message
    nil
  end
end
