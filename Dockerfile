# syntax=docker/dockerfile:1.4
FROM golang:trixie AS builder
ENV CGO_ENABLED=0
RUN go install github.com/aptible/supercronic@v0.2.49
RUN go install github.com/canonical/pebble/cmd/pebble@v1.33.0

FROM ubuntu:26.04

RUN <<EOT
  set -ex;
  apt-get update;
  env DEBIAN_FRONTEND=noninteractive         \
  apt-get install -y --no-install-recommends \
    ca-certificates                          \
    curl                                     \
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
    php8.5-zip                               \
    wait-for-it                              \
  ;
  rm -rf /var/lib/apt/lists/*
EOT

ARG GLPI_VERSION=11.0.11
ARG GLPI_SHA256=b918b1df4900e008cfc02d84bc9c57eae661e7075465f50b301ec5582b134de2
RUN <<EOT
  set -ex;
  base=https://github.com/glpi-project/glpi/releases/download
  filename=glpi-${GLPI_VERSION}.tgz
  curl --fail --silent --show-error --location --output "$filename" \
       "${base}/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz"
  echo "${GLPI_SHA256}  $filename" | sha256sum -c -
  tar -C /var/www/ -xf "$filename"
  rm "$filename"
EOT

COPY --from=builder /go/bin/ /usr/local/bin/
COPY /fs /

RUN chown -R www-data:www-data /var/www/glpi /var/lib/pebble /var/lib/nginx /var/log/nginx /run

USER www-data
WORKDIR /var/www/glpi

ENTRYPOINT [ "/entrypoint.sh" ]
