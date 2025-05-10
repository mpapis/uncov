# frozen_string_literal: true

# represents file line coverage in report
class Uncov::Report::File::Line < Uncov::Struct.new(:number, :content, :simple_cov, :no_cov, :context, :git_diff)
  def uncov?
    simple_cov == false && !no_cov
  end

  def covered?
    simple_cov == true && !no_cov
  end

  def display?
    uncov? || context
  end

  def relevant?
    [false, true].include?(simple_cov) && !no_cov
  end
end
