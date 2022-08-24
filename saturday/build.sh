#!/usr/bin/env bash
set -o errexit

echo "Getting deps..."
mix deps.get --only prod

echo "Compiling project..."
MIX_ENV=prod mix compile

echo "Deploying assets..."
MIX_ENV=prod mix phx.digest

echo "Creating release..."
MIX_ENV=prod mix release --overwrite