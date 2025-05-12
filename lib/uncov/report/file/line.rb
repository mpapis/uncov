# frozen_string_literal: true

# represents file line coverage in report
class Uncov::Report::File::Line < Uncov::Struct.new(:number, :content, :simple_cov, :no_cov, :context, :git_diff)
  def no_cov
    return false if Uncov.configuration.nocov_ignore

    self[:no_cov]
  end

  def uncov?
    simple_cov == false && !no_cov
  end

  def nocov_covered?
    # :nocov
    Uncov.configuration.nocov_covered && simple_cov == true && self[:no_cov]
    # :nocov
  end

  def covered?
    return false if Uncov.configuration.nocov_ignore && self[:no_cov]

    (simple_cov == true && !no_cov) ||
      (Uncov.configuration.nocov_covered && simple_cov == false && self[:no_cov])
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
