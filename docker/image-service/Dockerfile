# syntax=docker/dockerfile:1.4
# images - images service
# AUTO-GENERATED - DO NOT EDIT MANUALLY
# Edit ansible/roles/docker-common/tasks/generate-compose.yml and re-run ansible
#
# This Dockerfile supports multiple build methods:
#   - nexus: Download pre-built artifact from Nexus repository
#   - url: Download artifact from a custom URL
#   - repo-branch: Clone repository and build from a specific branch
#   - repo-commit: Clone repository and build from a specific commit
#
# Supports multiple runtime tools: tomcat, java-jar
#
# ============================================
# HOW TO SELECT BUILD_METHOD AND RUN_TOOL
# ============================================
# BUILD_METHOD selection: nexus | url | repo-branch | repo-commit
#   Usage: docker build --build-arg BUILD_METHOD=nexus ...
#   Default: nexus (fast, downloads pre-built artifact from ALA's nexus)
#
# RUN_TOOL selection: java-jar | tomcat
#   Usage: docker build --build-arg RUN_TOOL=tomcat ...
#   Default: java-jar (lightweight, runs WAR directly)
#
# ============================================
# GLOBAL BUILD ARGUMENTS
# ============================================
ARG BUILDER_IMAGE=gradle-builder:jdk21
ARG BUILD_METHOD=nexus
ARG BUILD_TOOL=gradle
ARG RUN_TOOL=java-jar

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

ARG VERSION=3.1.0
ARG ARTIFACT=image-service
ARG CLASSIFIER=exec

RUN echo "🔍 Preparing download from Nexus..." && \
    echo "   Version: ${VERSION}" && \
    echo "   Artifact: ${ARTIFACT}"

RUN --mount=type=cache,target=/cache/nexus,sharing=locked \
    set -e && \
    NEXUS_BASE_URL="https://nexus.ala.org.au/repository/releases" && \
    ARTIFACT_NAME="${ARTIFACT}-${VERSION}" && \
    if [ -n "${CLASSIFIER}" ] && [ "${CLASSIFIER}" != "" ]; then \
        ARTIFACT_NAME="${ARTIFACT_NAME}-${CLASSIFIER}"; \
    fi && \
    NEXUS_URL="${NEXUS_BASE_URL}/au/org/ala/${ARTIFACT}/${VERSION}/${ARTIFACT_NAME}.war" && \
    CACHE_FILE="/cache/nexus/${ARTIFACT}-${VERSION}${CLASSIFIER:+-${CLASSIFIER}}.war" && \
    echo "📥 Downloading from: ${NEXUS_URL}" && \
    if [ -f "${CACHE_FILE}" ]; then \
        echo "💾 Using cached artifact" && \
        cp "${CACHE_FILE}" artifact.war; \
    else \
        echo "⬇️  Fetching from Nexus..." && \
        curl -f -L -o artifact.war "${NEXUS_URL}" && \
        cp artifact.war "${CACHE_FILE}"; \
    fi && \
    ls -lh artifact.war && \
    echo "✅ Download completed"

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

ARG REPO=https://github.com/AtlasOfLivingAustralia/image-service
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

ARG REPO=https://github.com/AtlasOfLivingAustralia/image-service
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
# Stage 7: Runtime - Tomcat
# ============================================
FROM tomcat:9-jre21 AS runtime-tomcat

LABEL org.opencontainers.image.title="images"
LABEL org.opencontainers.image.description="images service"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/image-service"

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=final-builder /build/artifact.war /usr/local/tomcat/webapps/images.war

HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=3 CMD \
curl --fail --silent http://localhost:8080/images/actuator/health || exit 1

EXPOSE 8080

CMD ["catalina.sh", "run"]

# ============================================
# Stage 8: Runtime - Java JAR
# ============================================
FROM eclipse-temurin:21-jre-jammy AS runtime-java-jar

LABEL org.opencontainers.image.title="images"
LABEL org.opencontainers.image.description="images service"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/image-service"

WORKDIR /app

COPY --from=final-builder /build/artifact.war /app/app.war

HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=3 CMD \
curl --fail --silent http://localhost:8080/images/actuator/health || exit 1

EXPOSE 8080

CMD ["java", "-jar", "/app/app.war"]

# ============================================
# Stage 9: Final stage selection
# ============================================
# This stage selects the appropriate runtime based on RUN_TOOL argument
# The FROM instruction uses variable substitution: runtime-tomcat, runtime-java-jar
# Only the selected runtime stage is used; others are ignored
# Example: --build-arg RUN_TOOL=tomcat will use runtime-tomcat
# hadolint ignore=DL3006
FROM runtime-${RUN_TOOL}

RUN mkdir -p /data && \
    chown 1000:1000 /data

VOLUME /data
USER 1000:1000

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=3.1.0

LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.version="${VERSION}"

