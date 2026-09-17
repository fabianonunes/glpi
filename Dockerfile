# syntax=docker/dockerfile:1.4
FROM golang:bookworm as builder
RUN go install github.com/aptible/supercronic@v0.2.49
RUN go install github.com/canonical/pebble/cmd/pebble@v1.32.2

FROM ubuntu:26.04

RUN <<EOT
  set -ex;
  apt-get update;
  env DEBIAN_FRONTEND=noninteractive         \
  apt-get install -y --no-install-recommends \
    ca-certificates                          \
    curl                                     \
    gosu                                     \
    nginx                                    \
    php8.5-bcmath                            \
    php8.5-bz2                               \
    php8.5-curl                              \
    php8.5-fpm                               \
    php8.5-gd                                \
    php8.5-intl                              \
    php8.5-ldap                              \
    php8.5-mbstring                          \
    php8.5-mysql                             \
    php8.5-xml                               \
    php8.5-xmlrpc                            \
    php8.5-zip                               \
    wait-for-it                              \
    xz-utils                                 \
  ;
  rm -rf /var/lib/apt/lists/*
EOT

ARG GLPI_VERSION=11.0.9
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
