#!/bin/sh
# Does this package actually work in Qwen Code?
#
# Everything happens in a throwaway HOME, so the person's own Qwen Code (~/.qwen) is not touched.
# What is checked is the path a newcomer walks: install the package from this working copy and see
# what Qwen made of it.
#
# Run it from anywhere:  sh check.sh

set -eu

repo=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

HOME="$work/home"
mkdir -p "$HOME"
export HOME

fail() {
  echo "FAILED: $1" >&2
  exit 1
}

echo "1. the install"
printf 'y\n' | qwen extensions install "$repo" >"$work/install.txt" 2>&1 || fail "qwen would not install the package
$(cat "$work/install.txt")"
grep -q '\* nido:' "$work/install.txt" || fail "the install does not name the nido skill
$(cat "$work/install.txt")"

echo "2. what Qwen made of it"
qwen extensions list >"$work/list.txt" 2>&1 || fail "qwen extensions list did not run"
grep -q 'nido (' "$work/list.txt" || fail "the extension is not installed
$(cat "$work/list.txt")"
sed -n '/Skills:/,$p' "$work/list.txt" | grep -q 'nido' || fail "the extension is installed but its skill is not
$(cat "$work/list.txt")"

echo
echo "Both passed."
