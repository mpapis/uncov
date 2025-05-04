# What is uncov?
`uncov` stands for uncovered code.


## Why uncov
I was irritated by manually checking which files were changed in git
and then looking at each file coverage report for missing coverage.


## Why code coverage
This was tiresome but something that I thought was required to validate
if I thought about important behaviors of my code in tests.


## Code coverage is worthless
Code coverage does not indicate quality of the tests,
but lack of coverage indicates lack of testing specific behavior at all.

Despite its limitations as a quality metric, we can use coverage insights
as a starting point to develop better testing practices. Here's how:

## How to improve quality of tests
Think about testing behaviors, do not test implementation.
This implies more work preparing test data / the state of the system,
in a way that shows how the system behaves in specific conditions.

There has been a lot written about how to test, learn how others approach testing/coverage:
- https://testdesiderata.com/
- https://martinfowler.com/bliki/TestCoverage.html
- https://martinfowler.com/articles/practical-test-pyramid.html
- https://www.betterspecs.org/

There is a lot of gold in there, but I do not agree with everything there,
you need to find your own way that works for your specific project needs.


## How uncov helps
`uncov` focuses your attention where it matters most - on recently changed code that lacks test coverage.
By analyzing git diffs and connecting them to your test coverage results, `uncov`:
- Identifies only the files you've modified, saving you time
- Shows precisely which changed lines remain untested
- Integrates with your existing test workflow through SimpleCov
- Provides context around uncovered code to help you understand what needs testing

This targeted approach helps you maintain high-quality tests for new and modified code
without getting overwhelmed by legacy coverage issues.


## Take action
Ready to improve your testing workflow?

Install uncov with `gem install uncov` and run it after making changes to immediately see which behaviors need tests.
Check the [README](README.md) for more details and
`uncov -h` for configuration options to customize uncov for your project's needs.
