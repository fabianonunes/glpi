#!/bin/bash
set -ex

wait-for-it "${DB_HOST:?}":"${DB_PORT:-3306}" -t 60

cd /var/www/glpi || exit

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

rm -f install/install.php

if [[ -n $GLPICRYPT_KEY ]]; then
  echo -n "$GLPICRYPT_KEY" > config/glpicrypt.key
fi

php bin/console database:enable_timezones || true
php bin/console db:update --no-interaction --no-telemetry
