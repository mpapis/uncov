# frozen_string_literal: true

# represents file line coverage in report
class Uncov::Report::File
  Line = Struct.new('Line', :number, :content, :simple_cov, :no_cov, :git_diff) do
    def covered? = simple_cov != false || no_cov
    def relevant? = !no_cov
  end
end
