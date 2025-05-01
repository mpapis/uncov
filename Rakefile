# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new(:lint)
RSpec::Core::RakeTask.new(:test)

task(:coverage_env) { ENV['COVERAGE'] = 'true' }

desc 'Check new code coverage'
task('uncov') { system 'uncov' }

desc 'Run: lint, test, uncov'
task default: %i[lint coverage_env test uncov]
