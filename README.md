# Uncov
Uncov analyzes test coverage for changed files in your Git repository, helping you ensure that all your recent changes are properly tested.


## Features
- Compare your working tree to a target branch
- Identify changed Ruby files
- Check test coverage for those changes using SimpleCov
- Run tests automatically for files without coverage data
- Generate reports of uncovered lines in changed files


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
With options:
```bash
uncov --target develop --path custom/coverage/path
```
Options
- `-t`, `--target BRANCH`: Target branch for comparison (default: HEAD)
- `-c`, `--command COMMAND`: Test command to run (default: bundle exec rake test)
- `-p`, `--path PATH`: Path to SimpleCov results (default: coverage/.resultset.json)
- `-h`, `--help`: Display help
- `-v`, `--version`: Display version


## Requirements
- Ruby 3.2+
- A Git repository
- SimpleCov for test coverage


## Contributing
Contributing, developing, pull requests, releasing, security -> [CONTRIBUTING.md](CONTRIBUTING.md).


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
