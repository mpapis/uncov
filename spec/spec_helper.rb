# frozen_string_literal: true

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.warnings = true
  config.example_status_persistence_file_path = 'spec/.failures.txt'
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10
end

require 'simplecov'
require 'simplecov_json_formatter'

if ENV['COVERAGE']
  # See rails defaults: https://github.com/simplecov-ruby/simplecov/blob/efdb08db63b35577b3b0d79db893ead1d848d8dd/lib/simplecov/profiles/bundler_filter.rb
  SimpleCov.start 'bundler_filter' do
    # Additional coverage missing detection
    enable_coverage :branch

    SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
  end

  # require all files so coverage is reported properly
  Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].sort_by { |f| [f.count('/'), f] }.each { |f| require f }
end
