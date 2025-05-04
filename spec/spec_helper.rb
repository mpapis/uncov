# frozen_string_literal: true

# Do NOT name files in spec/support with suffix _spec.rb, those files would be required twice.
Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }
require 'open3'

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    # Do not truncate object.inspect - show proper diff's
    expectations.max_formatted_output_length = nil
  end
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
  # This option will default to `:apply_to_host_groups` in RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.example_status_persistence_file_path = 'spec/.failures.txt'
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed

  config.define_derived_metadata { |metadata| metadata[:aggregate_failures] = true }

  config.before(:suite) do
    Dir.chdir('spec/fixtures/project')
    system_run('./prepare.sh')
  end

  config.after { Uncov.configuration_reset! }

  config.after(:suite) { system_run('./cleanup.sh full') }

  config.before(:each, :branch) do |example|
    branch_name = example.metadata[:branch]
    case branch_name
    when *allowed_branches
      system_run("git checkout -f #{branch_name}")
    else
      raise "branch: #{branch_name.inspect} not in: #{allowed_branches.inspect}, example tagging: branch: 'master'"
    end
  end

  config.after(:each, :branch) do |example|
    branch_name = example.metadata[:branch]
    system_run('./cleanup.sh')
    system_run('git clean -f')
    system_run("git reset --hard #{branch_name}")
  end

  def system_run(command)
    stdout, _stderr, status = Open3.capture3("#{command} 2>&1")
    return if status.success?

    raise "#{command.inspect} failed(#{status}), output:\n#{stdout}"
  end

  def allowed_branches
    stdout, stderr, status = Open3.capture3('git branch --list --no-column --no-color | cut -c 3-')
    raise "#{stderr.inspect} failed(#{status}), output:\n#{stdout}" unless status.success?

    stdout.split("\n")
  end
end

if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov_json_formatter'

  # See defaults: https://github.com/simplecov-ruby/simplecov/blob/efdb08db63b35577b3b0d79db893ead1d848d8dd/lib/simplecov/profiles/bundler_filter.rb
  SimpleCov.start 'bundler_filter' do
    # Additional coverage missing detection
    enable_coverage :branch
    # self.formatters = [SimpleCov::Formatter::JSONFormatter]
  end
end

# Require all files for coverage, but also to prevent manually requiring dependencies in spec and lib/files
Dir["#{__dir__}/../lib/**/*.rb"].sort_by { |f| [f.count('/'), f] }.each { |f| require f }
