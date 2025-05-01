# frozen_string_literal: true

# handle configuration for uncov
class Uncov::Configuration
  FILE_MATCH_FLAGS = File::FNM_EXTGLOB | File::FNM_PATHNAME | File::FNM_DOTMATCH
  attr_accessor :git_diff_target, :report, :output_format, :path, :relevant_files, :simplecov_output_path, :test_command

  def initialize
    @git_diff_target = 'HEAD'
    @test_command = 'COVERAGE=true bundle exec rake test'
    @simplecov_output_path = 'autodetect'
    @path = '.'
    @relevant_files = ['{bin,exe,exec}/*', '{app,lib}/**/*.{rake,rb}', 'Rakefile']
    @report = :diff_lines
    @output_format = :terminal
  end
end
