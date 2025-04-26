# frozen_string_literal: true

require_relative 'lib/uncov/version'

Gem::Specification.new do |spec|
  spec.name = 'uncov'
  spec.version = Uncov::VERSION
  spec.authors = ['Michał Papis']
  spec.email = ['mpapis@gmail.com']

  spec.summary = 'Analyze test coverage for changed files in your git repository'
  spec.description = 'uncov compares your current branch with a target branch, ' \
                     'identifies changed files, and reports on test coverage for those changes'
  spec.homepage = 'https://github.com/mpapis/uncov'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/develop/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob(%w[lib/**/*.rb bin/uncov *.md LICENSE.txt])
  spec.bindir = 'bin'
  spec.executables = ['uncov']
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize', '~> 1.1'
  spec.add_dependency 'git', '~> 3.0'
  spec.add_dependency 'git_diff_parser', '~> 4.0'
  spec.add_dependency 'logger', '~> 1.7'
end
