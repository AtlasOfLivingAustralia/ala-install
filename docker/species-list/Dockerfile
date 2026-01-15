# syntax=docker/dockerfile:1.4
# species_lists - user provided species lists
# AUTO-GENERATED - DO NOT EDIT MANUALLY
# Edit ansible/roles/docker-common/tasks/generate-compose.yml and re-run ansible
#
# This Dockerfile supports multiple build methods:
#   - nexus: Download pre-built artifact from Nexus repository
#   - url: Download artifact from a custom URL
#   - repo-branch: Clone repository and build from a specific branch
#   - repo-commit: Clone repository and build from a specific commit
#
# Supports Java JAR runtime
#
# ============================================
# HOW TO SELECT BUILD_METHOD
# ============================================
# BUILD_METHOD selection: nexus | url | repo-branch | repo-commit
#   Usage: docker build --build-arg BUILD_METHOD=nexus ...
#   Default: nexus (fast, downloads pre-built artifact from ALA's nexus)
#
# ============================================
# GLOBAL BUILD ARGUMENTS
# ============================================
ARG BUILDER_IMAGE=gradle-builder:jdk11
ARG BUILD_METHOD=nexus
ARG BUILD_TOOL=gradle
ARG RUN_TOOL=java-jar
ARG HTTP_PROXY
ARG HTTPS_PROXY

# ============================================
# Stage 1: Base builder image
# ============================================
FROM ${BUILDER_IMAGE} AS base-builder

WORKDIR /build

# Ensure bash is available for all stages
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ============================================
# Stage 2: Build from Nexus
# ============================================
FROM base-builder AS builder-nexus

ARG VERSION=5.3.0
ARG ARTIFACT=specieslist-webapp
ARG CLASSIFIER=""

RUN echo "🔍 Preparing download from Nexus..." && \
    echo "   Version: ${VERSION}" && \
    echo "   Artifact: ${ARTIFACT}"

RUN --mount=type=cache,target=/cache/nexus,sharing=locked bash -c 'set -e; echo "📦 Building artifact name..."; ARTIFACT_NAME="${ARTIFACT}-${VERSION}"; if [ -n "${CLASSIFIER}" ] && [ "${CLASSIFIER}" != "" ]; then ARTIFACT_NAME="${ARTIFACT_NAME}-${CLASSIFIER}"; fi; echo "🏗️  Artifact: ${ARTIFACT_NAME}"; NEXUS_BASE_URL="https://nexus.ala.org.au/repository/releases"; NEXUS_URL="${NEXUS_BASE_URL}/au/org/ala/${ARTIFACT}/${VERSION}/${ARTIFACT_NAME}.war"; CACHE_FILE="/cache/nexus/${ARTIFACT}-${VERSION}${CLASSIFIER:+-${CLASSIFIER}}.war"; echo "📥 Target: ${NEXUS_URL}"; if [ -f "${CACHE_FILE}" ]; then echo "💾 Cache hit! Using cached artifact..."; cp "${CACHE_FILE}" artifact.war; else echo "⬇️  Cache miss. Fetching from Nexus..."; curl -f -L -o artifact.war "${NEXUS_URL}"; echo "💾 Saving to cache..."; cp artifact.war "${CACHE_FILE}"; fi; echo "📋 Artifact details:"; ls -lh artifact.war; echo "✅ Download completed"'

# ============================================
# Stage 3: Build from URL
# ============================================
FROM base-builder AS builder-url

ARG ARTIFACT_URL=""

RUN if [ -z "${ARTIFACT_URL}" ]; then \
        echo "❌ ERROR: ARTIFACT_URL must be specified for url build method"; \
        exit 1; \
    fi && \
    echo "✅ ARTIFACT_URL is set"

RUN echo "🔍 Downloading from URL..." && \
    echo "   URL: ${ARTIFACT_URL}"

RUN curl -f -L -o artifact.war "${ARTIFACT_URL}" && \
    ls -lh artifact.war && \
    echo "✅ Download completed"

# ============================================
# Stage 4: Build from Repository Branch
# ============================================
FROM base-builder AS builder-repo-branch

ARG REPO=https://github.com/AtlasOfLivingAustralia/specieslist-webapp
ARG BRANCH=develop
ARG BUILD_TOOL=gradle

RUN echo "🔍 Cloning repository..." && \
    echo "   Repo: ${REPO}"

RUN git clone "${REPO}" . && \
    git log -1 --oneline && \
    echo "✅ Repository cloned"

RUN echo "📦 Checking out branch: ${BRANCH}"

RUN git checkout "${BRANCH}" && \
    git log -1 --oneline && \
    echo "✅ Branch checked out"

RUN echo "🔨 Building with ${BUILD_TOOL}..."

RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew clean war -x test --no-daemon --max-workers=1 && \
    mv build/libs/*.war artifact.war

RUN ls -lh artifact.war && \
    echo "✅ Build completed successfully"

# ============================================
# Stage 5: Build from Repository Commit
# ============================================
FROM base-builder AS builder-repo-commit

ARG REPO=https://github.com/AtlasOfLivingAustralia/specieslist-webapp
ARG COMMIT=HEAD
ARG BUILD_TOOL=gradle

RUN echo "🔍 Cloning repository..." && \
    echo "   Repo: ${REPO}"

RUN git clone "${REPO}" . && \
    git log -1 --oneline && \
    echo "✅ Repository cloned"

RUN echo "📦 Checking out commit: ${COMMIT}"

RUN git checkout "${COMMIT}" && \
    git log -1 --oneline && \
    echo "✅ Commit checked out"

RUN echo "🔨 Building with ${BUILD_TOOL}..."

RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew clean war -x test --no-daemon --max-workers=1 && \
    mv build/libs/*.war artifact.war

RUN ls -lh artifact.war && \
    echo "✅ Build completed successfully"

# ============================================
# Stage 6: Consolidate build stages
# ============================================
# This stage selects the appropriate builder based on BUILD_METHOD argument
# The FROM instruction uses variable substitution: builder-nexus, builder-url, etc
# Only the selected builder stage is used; others are ignored
# Example: --build-arg BUILD_METHOD=repo-branch will use builder-repo-branch
# hadolint ignore=DL3006
FROM builder-${BUILD_METHOD} AS final-builder

# ============================================
# Stage 7: Final Runtime - Java JAR with setup
# ============================================
FROM eclipse-temurin:11-jre-jammy

ARG SERVICE_USER=species_lists
ARG APP_ARTIFACT=specieslist-webapp
ARG LOG_DIR=

LABEL org.opencontainers.image.title="species_lists"
LABEL org.opencontainers.image.description="user provided species lists"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/specieslist-webapp"

WORKDIR /opt/atlas/$APP_ARTIFACT

COPY --from=final-builder /build/artifact.war /app/app.war

# Default JAVA_OPTS can be overridden via docker-compose environment variables
ENV JAVA_OPTS="-Djava.awt.headless=true -Xmx2g -Xms1g"

HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=3 CMD \
curl --fail --silent http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

# Create service user and data directories
RUN groupadd -r ${SERVICE_USER} -g 1000 && \
    useradd -r -g ${SERVICE_USER} -u 1000 -m ${SERVICE_USER} && \
    mkdir -p /data/${APP_ARTIFACT}/config && \
    mkdir -p /data/${APP_ARTIFACT}/data && \
    chown -R ${SERVICE_USER}:${SERVICE_USER} /data/${APP_ARTIFACT} && \
    chown ${SERVICE_USER}:${SERVICE_USER} /app/app.war


VOLUME /data

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to service user for runtime execution
USER ${SERVICE_USER}

# Set entrypoint to fix permissions at runtime, then execute CMD
ENTRYPOINT ["/entrypoint.sh"]

# Execute service
CMD ["sh", "-c", "java ${JAVA_OPTS} -jar /app/app.war"]

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=5.3.0

LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.version="${VERSION}"

