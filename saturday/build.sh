#!/usr/bin/env
set -o errexit

mix deps.get --only prod
MIX_ENV=prod mix compile

MIX_ENV=prod mix assets.deploy
# mix phx.digest

MIX_ENV=prod mix release --overwrite