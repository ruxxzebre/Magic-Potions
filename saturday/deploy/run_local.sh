#!/usr/bin/env bash

DATABASE_PATH=$(pwd)/db \
SECRET_KEY_BASE=$(mix phx.gen.secret) \
_build/prod/rel/production/bin/production start
