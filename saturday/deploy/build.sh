#!/usr/bin/env bash
set -o errexit

echo "Getting deps..."
mix deps.get --only prod

echo "Compiling project..."
MIX_ENV=prod mix compile

echo "Deploying assets..."
MIX_ENV=prod mix cmd --app saturday_web mix assets.deploy

echo "Creating release..."
MIX_ENV=prod mix release production --overwrite