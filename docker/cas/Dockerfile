# syntax=docker/dockerfile:1.4
# ALA CAS 5/6 Server
# Multi-stage build: gradle-builder -> runtime

ARG GRADLE_BUILDER_IMAGE=gradle:7-jdk17-jammy
ARG RUNTIME_IMAGE=eclipse-temurin:17-jre-jammy

# ============================================
# Stage 1: Build
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG CAS_VERSION=6.5.6-3
ARG CAS_REPO=https://github.com/AtlasOfLivingAustralia/ala-cas-5.git
ARG CAS_BRANCH=master

WORKDIR /build

# Clone and checkout specific version/branch
RUN git clone ${CAS_REPO} . && \
    if [ "${CAS_BRANCH}" != "master" ]; then \
        git checkout ${CAS_BRANCH}; \
    fi && \
    if [ "${CAS_VERSION}" != "develop" ]; then \
        git checkout ${CAS_VERSION} || git checkout tags/v${CAS_VERSION} || true; \
    fi

# Build the WAR file
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew clean bootWar -x test --no-daemon

# ============================================
# Stage 2: Runtime
# ============================================
FROM ${RUNTIME_IMAGE}

LABEL org.opencontainers.image.title="ALA CAS"
LABEL org.opencontainers.image.description="Atlas of Living Australia CAS Authentication Server"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/ala-cas-5"

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Install dockerize for wait-for dependencies
ENV DOCKERIZE_VERSION=v0.7.0
RUN curl -sfL https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    | tar -C /usr/local/bin -xz

# Create CAS user
RUN groupadd -r cas && useradd -r -g cas cas

WORKDIR /opt/atlas/cas

# Copy built WAR from builder
COPY --from=builder /build/build/libs/*.war ./cas.war

# Fix permissions for WAR file
RUN chown cas:cas /opt/atlas/cas/cas.war

USER cas

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl --fail http://localhost:8080/cas/status || exit 1

# Start with dockerize to wait for dependencies
ENTRYPOINT ["sh", "-c", "exec dockerize ${DOCKERIZE_OPTS} java ${JAVA_OPTS} -Dspring.config.additional-location=file:/data/cas/config/ -jar cas.war"]

