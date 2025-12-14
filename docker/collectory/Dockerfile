# syntax=docker/dockerfile:1.4
# ALA Collectory Service
# Multi-stage build: gradle-builder -> runtime

ARG GRADLE_BUILDER_IMAGE=gradle-builder:jdk17
ARG RUNTIME_IMAGE=tomcat:9-jre17

# ============================================
# Stage 1: Build
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG COLLECTORY_VERSION=3.1.1
ARG COLLECTORY_REPO=https://github.com/AtlasOfLivingAustralia/collectory.git
ARG COLLECTORY_BRANCH=develop

WORKDIR /build

# Clone and checkout specific version/branch
RUN git clone ${COLLECTORY_REPO} . && \
    if [ "${COLLECTORY_BRANCH}" != "develop" ]; then \
        git checkout ${COLLECTORY_BRANCH}; \
    fi && \
    if [ "${COLLECTORY_VERSION}" != "develop" ]; then \
        git checkout ${COLLECTORY_VERSION} || git checkout tags/v${COLLECTORY_VERSION} || true; \
    fi

# Gradle configuration for better handling of wrapper downloads
ENV GRADLE_OPTS="-Dorg.gradle.internal.http.connectionTimeout=120000 -Dorg.gradle.internal.http.socketTimeout=120000"

# Build the WAR file (increased timeout for gradle wrapper download)
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew clean war -x test --no-daemon --max-workers=1

# ============================================
# Stage 2: Runtime
# ============================================
FROM ${RUNTIME_IMAGE}

LABEL org.opencontainers.image.title="ALA Collectory"
LABEL org.opencontainers.image.description="Atlas of Living Australia Collectory Service"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/collectory"

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Install dockerize
ENV DOCKERIZE_VERSION=v0.7.0
RUN curl -sfL https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    | tar -C /usr/local/bin -xz

# Create directories with proper permissions for tomcat
RUN mkdir -p /data/collectory/config /data/collectory/data /data/collectory/upload && \
    chmod 755 /data/collectory && \
    chmod 755 /data/collectory/config && \
    chmod 755 /data/collectory/data && \
    chmod 755 /data/collectory/upload

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR from builder
COPY --from=builder --chown=tomcat:tomcat /build/build/libs/*.war /usr/local/tomcat/webapps/collectory.war

# Set config location
ENV CATALINA_OPTS="-Dcollectory.config=file:/data/collectory/config/collectory-config.properties"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl --fail http://localhost:8080/collectory/actuator/health || exit 1

# Start with dockerize
ENTRYPOINT ["sh", "-c", "exec dockerize ${DOCKERIZE_OPTS} catalina.sh run"]

