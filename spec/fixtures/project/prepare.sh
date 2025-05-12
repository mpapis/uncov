#!/usr/bin/env bash

set -ex
save_file() { cat > $1; }
add_to_file() { cat >> $1; }

./cleanup.sh full
mkdir -p lib/ spec/lib/

git init -b clean
git config --global --add safe.directory $PWD
git config user.email "generator@example.com"
git config user.name "Example Generator"

save_file .gitignore <<EOF
/coverage/*
/*.sh
/spec/.failures.txt
EOF

save_file .rspec <<EOF
--require project_spec_helper
EOF

save_file .uncov <<EOF
--test-command
COVERAGE=1 rspec
EOF

save_file lib/project.rb <<EOF
# :nocov:
def inc(a)
  a + 1
end

def prec(str)
  return 'a' if str == 'b'

  'b'
end
# :nocov:
EOF

save_file spec/project_spec_helper.rb <<EOF
RSpec.configure do |config|
  config.example_status_persistence_file_path = nil
end
if ENV['COVERAGE'] || ENV['COVERAGE_JSON']
  require 'simplecov'
  require 'simplecov_json_formatter' if ENV['COVERAGE_JSON']
  SimpleCov.start 'bundler_filter' do
    add_filter '/spec/'
    if ENV['COVERAGE_JSON']
      formatter SimpleCov::Formatter::JSONFormatter
      use_merging false
    end
  end
end
EOF

save_file spec/lib/project_spec.rb <<EOF
require_relative '../../lib/project'
EOF

git add .
git commit -m "Empty"

git checkout -b develop

add_to_file lib/project.rb <<EOF

def dec(a)
  1
end
EOF

git commit -a -m "Code"


git checkout -b develop_coverage_json

add_to_file .gitignore <<EOF
!/coverage/coverage.json
EOF
COVERAGE_JSON=1 rspec
git add .gitignore coverage/coverage.json
git commit -m 'Failing coverage.json'


git checkout develop
git checkout -b develop_a

add_to_file lib/project.rb <<EOF

def succ(a)
  'b'
end
EOF

git commit -a -m "Extra Code"


git checkout -b develop_a_coverage_json

add_to_file .gitignore <<EOF
!/coverage/coverage.json
EOF
COVERAGE_JSON=1 rspec
git add .gitignore coverage/coverage.json
git commit -m 'Failing coverage.json'


git checkout develop_a
git checkout -b test

add_to_file spec/lib/project_spec.rb <<EOF
RSpec.describe('#dec') { it { expect(dec(2)).to eq(1) } }
RSpec.describe('#succ') { it { expect(succ('a')).to eq('b') } }
EOF

git commit -a -m "Test"
git tag v1


git checkout -b test_coverage_json

add_to_file .gitignore <<EOF
!/coverage/coverage.json
EOF
COVERAGE_JSON=1 rspec
git add .gitignore coverage/coverage.json
git commit -m 'Success coverage.json'


git checkout test
git checkout -b test_coverage_resultset

add_to_file .gitignore <<EOF
!/coverage/.resultset.json
EOF
COVERAGE=1 rspec
git add .gitignore coverage/.resultset.json
git commit -m 'Success .resultset.json'


git checkout -b develop_nocov_coverage

add_to_file spec/lib/project_spec.rb <<EOF
RSpec.describe('#prec') { it { expect(prec('b')).to eq('a') } }
EOF
COVERAGE=1 rspec
git add spec/lib/project_spec.rb coverage/.resultset.json
git commit -m 'Nocov covered with coverage.json'
