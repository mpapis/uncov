# Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/mpapis/uncov.

Do not know where to start? Help triaging issues, make sure they can be reproduced.


## Reporting a Vulnerability

If you discover a security vulnerability within uncov, please email [mpapis@gmail.com](mailto:mpapis@gmail.com).
All security vulnerabilities will be promptly addressed.

## Development
- `docker-compose build uncov` to (re-)build dev container,
- `docker-compose run uncov` to enter dev container,
- `bundle` to install dependencies,
- `rake` to run test and lint,
- `rake install` to install the gem,
- `uncov` to see uncovered changes (check itself)


## Pull requests

Open pull requests against the `develop` branch

Branch prefix influences auto labeling next release:
- `ignore/` - will not trigger next release (excluded from changelog),
- `fix/` - will bump patch version,
- `feature/` - will bump minor version,
- `breaking/` - will bump major version.

If unsure it's not important, the release label's can be changed by maintainers.


## Release Process

This gem uses GitHub Actions for continuous integration and automated releases. Here's how the release process works:

1. Go to the "Actions" tab in the GitHub repository
2. Select the "Release" workflow
3. Click "Run workflow"

This will:
- Generate a changelog based on PRs since the last release,
- Increment the version number appropriately based on changelog,
- Do the release to rubygems, git tag, and create release on github.


## Security Practices

This project follows these security practices:

1. **Code Review**:
    - All pull requests must be reviewed by a project maintainer
    - Workflow files cannot be modified without explicit review from core maintainers

2. The rubygems release process uses [trusted publishing](https://guides.rubygems.org/trusted-publishing/).
