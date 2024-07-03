# syntax=docker/dockerfile:1.4
FROM golang as builder
RUN go install github.com/canonical/pebble/cmd/pebble@v1.6.0

FROM ubuntu:22.04

RUN <<EOT
  set -ex;
  apt-get update;
  env DEBIAN_FRONTEND=noninteractive         \
  apt-get install -y --no-install-recommends \
    ca-certificates                          \
    curl                                     \
    gosu                                     \
    nginx                                    \
    php8.1-bz2                               \
    php8.1-curl                              \
    php8.1-fpm                               \
    php8.1-gd                                \
    php8.1-intl                              \
    php8.1-ldap                              \
    php8.1-mbstring                          \
    php8.1-mysql                             \
    php8.1-xml                               \
    php8.1-xmlrpc                            \
    php8.1-zip                               \
    wait-for-it                              \
    xz-utils                                 \
  ;
  rm -rf /var/lib/apt/lists/*
EOT

ARG GLPI_VERSION=10.0.15
RUN <<EOT
  set -ex;
  base=https://github.com/glpi-project/glpi/releases/download
  curl -JLO "${base}/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz"
  tar -C /var/www/ -xf "glpi-${GLPI_VERSION}.tgz"
  rm *.tgz
  chown -R www-data:www-data /var/www/glpi
EOT

COPY --from=builder /go/bin/pebble /usr/local/bin/pebble
COPY /fs /

WORKDIR /var/www/glpi

ENTRYPOINT [ "/entrypoint.sh" ]
