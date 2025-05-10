# Uncov
Uncov analyzes test coverage for changed files in your Git repository,
helping you ensure that all your recent changes are properly tested.

Uncov uses `git diff` to detect changes and `simplecov` reports to detect uncovered code.

[The uncov Manifesto](PHILOSOPHY.md)

![report diff_lines to terminal output](diff_lines_terminal.png)

## Features
- Compare your working tree to a target branch
- Identify changed Ruby files
- Run tests automatically for (changed) relevant files
- Print report of uncovered lines in (changed) files


## Installation
```bash
gem install uncov
```
Or add to your Gemfile (only for convenience):
```ruby
gem 'uncov', require: false
```


## Usage
Basic usage:
```bash
uncov
```

### Display configuration options
```bash
$ uncov -h
Usage: uncov [options]
    -t, --target TARGET              Target branch for comparison, default: "HEAD"
    -r, --report TYPE                Report type to generate, one_of: "diff_lines"(default)
    -o, --output-format FORMAT       Output format, one_of: "terminal"(default)
    -C, --context LINES_NUMBER       Additional lines context in output, default: 1
        --test-command COMMAND       Test command that generates SimpleCov, default: "COVERAGE=true bundle exec rake test"
        --simplecov-file PATH        SimpleCov results file, default: "autodetect"
        --relevant-files             Relevant files shell filename globing: https://ruby-doc.org/core-3.1.1/File.html#method-c-fnmatch, default: "{{bin,exe,exec}/*,{app,lib}/**/*.{rake,rb},Rakefile}"
        --debug                      Get some insights, default: false
    -v, --version                    Show version
    -h, --help                       Print this help
uncov 0.4.2 by Michal Papis <mpapis@gmail.com>
```


## Configuration file
`.uncov` file in the directory where it's ran stores default options,
specify one argument per line - this eliminates the need for special parsing of the file.

Example:
```text
--target
develop
--test-command
COVERAGE=1 rspec
```


## Using in CI
`uncov` uses itself to check new missing code coverage [.github/workflows/ci.yml](.github/workflows/ci.yml),
no need to set minimal, always get better.

Ideas for CI:
- run `uncov` after running your tests with coverage enabled,
- be less restrictive - provide custom `--relevant-files` pattern
  that excludes some paths you do not think should be always tested.


## Requirements
- Ruby 3.2+
- A Git repository
- SimpleCov for test coverage


## Contributing
Contributing, developing, pull requests, releasing, security -> [CONTRIBUTING.md](CONTRIBUTING.md).


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
