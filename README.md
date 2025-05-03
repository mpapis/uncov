# Uncov
Uncov analyzes test coverage for changed files in your Git repository,
helping you ensure that all your recent changes are properly tested.


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

Display configuration options:
```bash
uncov -h
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


## Requirements
- Ruby 3.2+
- A Git repository
- SimpleCov for test coverage


## Contributing
Contributing, developing, pull requests, releasing, security -> [CONTRIBUTING.md](CONTRIBUTING.md).


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
