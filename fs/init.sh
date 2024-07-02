#!/bin/bash
set -ex

wait-for-it "${DB_HOST:?}":"${DB_PORT:-3306}" -t 60

cd /var/www/glpi || exit

if [[ -n $GLPI_CRYPTKEY ]]; then
  echo "$GLPI_CRYPTKEY" > config/glpicrypt.key
fi

php bin/console db:install                   \
  --no-interaction                           \
  --reconfigure                              \
  --db-host "${DB_HOST}"                     \
  --db-port "${DB_PORT:-3306}"               \
  --db-name "${DB_DATABASE:?}"               \
  --db-user "${DB_USER:?}"                   \
  --db-password "${DB_PASSWORD:?}"           \
  --default-language "${DEFAULT_LANGUAGE:?}" \
|| true

rm install/install.php

php bin/console database:enable_timezones || true
php bin/console db:update --no-interaction --no-telemetry
