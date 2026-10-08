#!/bin/bash
set -ex

/init.sh

exec pebble run --verbose "$@"
