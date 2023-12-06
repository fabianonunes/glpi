#!/bin/bash
set -ex

gosu www-data:www-data /init.sh

exec pebble run --verbose "$@"
