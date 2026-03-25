#!/usr/bin/env bash
set -e

if [ -z "${LD_PRELOAD+x}" ]; then
  LD_PRELOAD=$(find /usr/lib -name libjemalloc.so.2 -print -quit)
  export LD_PRELOAD
fi

if [ "$1" = "bin/rails" ] && [ "$2" = "server" ]; then
  bin/rails db:prepare
fi

exec "$@"
