#!/bin/sh
# Check the version in `default.nix` and `Gemfile` and run `./generate.sh` if
# you update the gem version here.
#
# You need bundler and bundix in your path, get them from nixpkgs if necessary.
#
# Resources:
# https://github.com/NixOS/nixpkgs/issues/21073#issuecomment-266749641
# http://blog.arkency.com/2016/04/packaging-ruby-programs-in-nixos/

set -eu

BUNDLER=${BUNDLER:-"$(nix-build '<nixpkgs>' -A bundler)/bin/bundler"}
BUNDIX=${BUNDIX:-"$(nix-build '<nixpkgs>' -A bundix)/bin/bundix"}
TMPDIR=$(mktemp -d)

echo "Created temporary directory at ${TMPDIR}"

cleanup() {
  echo "Cleaning up..."
  rm -rv "${TMPDIR}" "./result"
}

trap 'cleanup' EXIT

# Prevent bundler from writing to "${HOME}/.bundle" by faking "${HOME}".
HOME="${TMPDIR}" "${BUNDLER}" lock
HOME="${TMPDIR}" "${BUNDIX}" --gemset="./gemset.nix" --lockfile="./Gemfile.lock"
sed -i "1s/^/# This file is automatically generated by \`generate.sh'; do not edit!\n\n/" "./gemset.nix" "./Gemfile.lock"
