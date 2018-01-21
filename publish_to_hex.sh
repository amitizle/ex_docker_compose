#!/usr/bin/env bash

echo "Make sure to bump version by 'mix version bump (major|minor|patch)'"
mix deps.get --only docs
MIX_ENV=docs mix docs
# The next two lines should be running on CI, if and when
# mix hex.config username $HEX_USERNAME
# mix hex.config key $HEX_KEY
mix hex.publish
