#!/usr/bin/env bash

SECRET_KEY_BASE=$(mix phx.gen.secret) \
_build/prod/rel/production/bin/production start
