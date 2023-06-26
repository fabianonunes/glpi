# syntax=docker/dockerfile:1.4
FROM ubuntu:22.04

RUN <<EOT
  set -ex;
  apt-get update;
  env DEBIAN_FRONTEND=noninteractive         \
  apt-get install -y --no-install-recommends \
    ca-certificates                          \
    curl                                     \
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

ARG S6_OVERLAY_VERSION=3.1.5.0
RUN <<EOT
  set -ex;
  base=https://github.com/just-containers/s6-overlay/releases/download
  curl -JLO "${base}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz"
  curl -JLO "${base}/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz"
  tar -C / -Jxpf s6-overlay-noarch.tar.xz
  tar -C / -Jxpf s6-overlay-x86_64.tar.xz
  rm *.tar.xz
EOT

ARG GLPI_VERSION=10.0.7
RUN <<EOT
  set -ex;
  base=https://github.com/glpi-project/glpi/releases/download
  curl -JLO "${base}/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz"
  tar -C /var/www/ -xf "glpi-${GLPI_VERSION}.tgz"
  rm *.tgz
EOT

COPY /fs /

ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

ENTRYPOINT ["/init"]
