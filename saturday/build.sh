#!/usr/bin/env
set -o errexit

mix deps.get --only prod
MIX_ENV=prod mix compile

mix phx.digest

MIX_ENV=prod mix release --overwrite