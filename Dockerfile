# syntax=docker/dockerfile:1.4
FROM golang:bookworm as builder
RUN go install github.com/aptible/supercronic@v0.2.39
RUN go install github.com/canonical/pebble/cmd/pebble@v1.25.0

FROM ubuntu:24.04

RUN <<EOT
  set -ex;
  apt-get update;
  env DEBIAN_FRONTEND=noninteractive         \
  apt-get install -y --no-install-recommends \
    ca-certificates                          \
    curl                                     \
    gosu                                     \
    nginx                                    \
    php8.3-bcmath                            \
    php8.3-bz2                               \
    php8.3-curl                              \
    php8.3-fpm                               \
    php8.3-gd                                \
    php8.3-intl                              \
    php8.3-ldap                              \
    php8.3-mbstring                          \
    php8.3-mysql                             \
    php8.3-xml                               \
    php8.3-xmlrpc                            \
    php8.3-zip                               \
    wait-for-it                              \
    xz-utils                                 \
  ;
  rm -rf /var/lib/apt/lists/*
EOT

ARG GLPI_VERSION=11.0.4
RUN <<EOT
  set -ex;
  base=https://github.com/glpi-project/glpi/releases/download
  curl -JLO "${base}/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz"
  tar -C /var/www/ -xf "glpi-${GLPI_VERSION}.tgz"
  rm *.tgz
  chown -R www-data:www-data /var/www/glpi
EOT

COPY --from=builder /go/bin/ /usr/local/bin/
COPY /fs /

WORKDIR /var/www/glpi

ENTRYPOINT [ "/entrypoint.sh" ]
