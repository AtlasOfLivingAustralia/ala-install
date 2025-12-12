# syntax=docker/dockerfile:1.14.0
# ALA i18n Data Image
# Pre-installs ala-i18n package to be used as init container or data volume
# Follows the same pattern as roles/la-apt + roles/i18n

ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}-slim

# Build argument for apt repository (unstable, testing, stable)
ARG LA_APT_REPO=unstable

LABEL org.opencontainers.image.title="ALA i18n Data"
LABEL org.opencontainers.image.description="Living Atlas i18n translations package"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/ala-install"

# Install ala-i18n package following roles/la-apt + roles/i18n pattern
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        ca-certificates && \
    # Add apt.gbif.es repository key (following roles/la-apt/tasks/main.yml)
    wget -qO /etc/apt/trusted.gpg.d/apt-gbif-es-demo.asc \
        'https://keyserver.ubuntu.com/pks/lookup?op=hget&search=7524d3b383016eab0ee47bfe253a51f7' && \
    # Add apt.gbif.es repository (following roles/la-apt/tasks/main.yml)
    echo "deb [arch=amd64] https://apt.gbif.es/ ${LA_APT_REPO} main" > /etc/apt/sources.list.d/apt_gbif_es.list && \
    # Install ala-i18n package (following roles/i18n/tasks/main.yml)
    apt-get update && \
    apt-get install -y --no-install-recommends ala-i18n && \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

# Verify installation
RUN test -d /opt/atlas/i18n && \
    ls -la /opt/atlas/i18n/ && \
    echo "✅ ala-i18n package installed successfully"

# The container doesn't need to run anything, it just provides the data
# It will be used as an init container or for data volume copying
CMD ["echo", "ala-i18n data container ready"]

