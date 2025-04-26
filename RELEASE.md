# Release Process

This gem uses GitHub Actions for continuous integration and automated releases. Here's how the release process works:

## For Contributors

1. Develop features in feature branches
2. Open pull requests against the `develop` branch
3. Ensure CI passes and get code review approval
4. Your changes will be included in the next release

## For Maintainers

### Preparing a Release

1. Go to the "Actions" tab in the GitHub repository
2. Select the "Prepare Release" workflow
3. Click "Run workflow"
4. Choose the version bump type (patch, minor, or major) following SemVer
5. Optionally select "Create pre-release" for release candidates
6. Click "Run workflow"

This will:
- Increment the version number appropriately
- Generate a changelog based on PRs since the last release
- Create a release branch and open a PR to main

### Finalizing a Release

1. Review and merge the auto-generated release PR into `main`
2. The system will automatically:
    - Create a git tag for the release
    - Run tests one final time
    - Build and publish the gem to RubyGems
    - Create a GitHub Release with the changelog

### Pre-releases

For pre-releases (e.g. v1.2.0.pre1):
1. Follow the normal preparation process but check "Create pre-release"
2. The gem will be published to RubyGems as a pre-release version
3. Users can install it with `gem install uncov --pre`

## Manual Override

If you need to create a release manually:
1. Update version in `lib/uncov/version.rb`
2. Update `CHANGELOG.md`
3. Commit these changes to `main`
4. Create and push a git tag: `git tag -a v1.2.3 -m "Release v1.2.3" && git push origin v1.2.3`
5. The tag will trigger the release workflow
