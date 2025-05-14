# frozen_string_literal: true

# represents file line coverage in report
class Uncov::Report::File::Line < Uncov::Struct.new(:number, :content, :simplecov, :nocov, :context, :git_diff)
  def nocov
    return false if Uncov.configuration.nocov_ignore

    self[:nocov]
  end

  def uncov?
    simplecov == false && !nocov
  end

  def nocov_covered?
    # :nocov
    Uncov.configuration.nocov_covered && simplecov == true && self[:nocov]
    # :nocov
  end

  def covered?
    return false if Uncov.configuration.nocov_ignore && self[:nocov]

    (simplecov == true && !nocov) ||
      (Uncov.configuration.nocov_covered && simplecov == false && self[:nocov])
  end

  def trigger?
    uncov? || nocov_covered?
  end

  def display?
    trigger? || context
  end

  def relevant?
    trigger? || covered?
  end
end
