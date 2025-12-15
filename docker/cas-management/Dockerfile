# syntax=docker/dockerfile:1.4
# ALA CAS Management
# Multi-stage build: gradle-builder -> runtime

ARG GRADLE_BUILDER_IMAGE=gradle:7-jdk11-jammy
ARG RUNTIME_IMAGE=eclipse-temurin:11-jre-jammy

# ============================================
# Stage 1: Build
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG CAS_MANAGEMENT_VERSION=6.5.5-2
ARG CAS_MANAGEMENT_REPO=https://github.com/AtlasOfLivingAustralia/ala-cas-5-services.git
ARG CAS_MANAGEMENT_BRANCH=master

WORKDIR /build

# Clone and checkout specific version/branch
RUN git clone ${CAS_MANAGEMENT_REPO} . && \
    if [ "${CAS_MANAGEMENT_BRANCH}" != "master" ]; then \
        git checkout ${CAS_MANAGEMENT_BRANCH}; \
    fi && \
    if [ "${CAS_MANAGEMENT_VERSION}" != "develop" ]; then \
        git checkout ${CAS_MANAGEMENT_VERSION} || git checkout tags/v${CAS_MANAGEMENT_VERSION} || true; \
    fi

# Build the WAR file
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew clean bootWar -x test --no-daemon

# ============================================
# Stage 2: Runtime
# ============================================
FROM ${RUNTIME_IMAGE}

LABEL org.opencontainers.image.title="ALA CAS Management"
LABEL org.opencontainers.image.description="Atlas of Living Australia CAS Management Interface"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/ala-cas-management"

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

# Create user for cas-management
RUN groupadd -r casmanagement && useradd -r -g casmanagement casmanagement

WORKDIR /opt/atlas/cas-management

# Copy built WAR from builder
COPY --from=builder /build/build/libs/*.war ./cas-management.war

# Fix permissions for WAR file
RUN chown casmanagement:casmanagement /opt/atlas/cas-management/cas-management.war

USER casmanagement

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl --fail http://localhost:8080/cas-management/ || exit 1

# Start with dockerize
ENTRYPOINT ["sh", "-c", "exec dockerize ${DOCKERIZE_OPTS} java ${JAVA_OPTS} -Dspring.config.additional-location=file:/data/cas-management/config/ -jar cas-management.war"]

