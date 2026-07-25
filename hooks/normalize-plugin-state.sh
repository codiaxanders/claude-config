#!/usr/bin/env bash
# Git clean filter for plugins/known_marketplaces.json and
# plugins/installed_plugins.json: zeroes out the timestamp fields that
# get bumped on every routine plugin check, so git only sees a diff when
# something that actually matters changes (a plugin/marketplace added,
# removed, or updated to a new version).
#
# Registered via .gitattributes + `git config filter.pluginstate.clean`
# (set up automatically by setup.sh). Only affects what git hashes for
# diff/add/commit — the real file on disk keeps its real timestamps.
set -euo pipefail

jq '
  (.. | objects | select(has("lastUpdated")) | .lastUpdated) |= "1970-01-01T00:00:00.000Z" |
  (.. | objects | select(has("installedAt")) | .installedAt) |= "1970-01-01T00:00:00.000Z"
'
