#!/usr/bin/env bash

set -ex

if [ "${1:-}" == "full" ]
then rm -rf .git .gitignore .rspec .uncov lib spec
fi

rm -rf coverage/{,.}*
