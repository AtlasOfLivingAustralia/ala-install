# syntax=docker/dockerfile:1.4
# ALA Species List Service
# Multi-stage build: gradle-builder -> runtime

ARG GRADLE_BUILDER_IMAGE=gradle-builder:jdk17
ARG RUNTIME_IMAGE=tomcat:9-jre17

# ============================================
# Stage 1: Build
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG SPECIES_LIST_VERSION=4.0.4
ARG SPECIES_LIST_REPO=https://github.com/AtlasOfLivingAustralia/specieslist-webapp.git
ARG SPECIES_LIST_BRANCH=master

WORKDIR /build

# Clone and checkout specific version/branch
RUN git clone ${SPECIES_LIST_REPO} . && \
    if [ "${SPECIES_LIST_BRANCH}" != "master" ]; then \
        git checkout ${SPECIES_LIST_BRANCH}; \
    fi && \
    if [ "${SPECIES_LIST_VERSION}" != "develop" ]; then \
        git checkout ${SPECIES_LIST_VERSION} || git checkout tags/v${SPECIES_LIST_VERSION} || true; \
    fi

# Build the WAR file
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew clean war -x test --no-daemon

# ============================================
# Stage 2: Runtime
# ============================================
FROM ${RUNTIME_IMAGE}

LABEL org.opencontainers.image.title="ALA Species List"
LABEL org.opencontainers.image.description="Living Atlas Species List Service"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/specieslist-webapp"

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

# Create directories
RUN mkdir -p /data/species-list/config /data/species-list/data /data/species-list/upload && \
    chown -R tomcat:tomcat /data/species-list

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR from builder
COPY --from=builder --chown=tomcat:tomcat /build/build/libs/*.war /usr/local/tomcat/webapps/specieslist.war

# Set config location
ENV CATALINA_OPTS="-Dspecieslist.config=file:/data/species-list/config/specieslist-config.properties"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl --fail http://localhost:8080/specieslist/ || exit 1

# Start with dockerize
ENTRYPOINT ["sh", "-c", "exec dockerize ${DOCKERIZE_OPTS} catalina.sh run"]

