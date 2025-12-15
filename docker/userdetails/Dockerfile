# syntax=docker/dockerfile:1.4
# ALA Userdetails Service
# Multi-stage build: gradle-builder -> runtime

ARG GRADLE_BUILDER_IMAGE=gradle:7-jdk11-jammy
ARG RUNTIME_IMAGE=tomcat:9-jre11

# ============================================
# Stage 1: Build
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG USERDETAILS_VERSION=3.0.2
ARG USERDETAILS_REPO=https://github.com/AtlasOfLivingAustralia/userdetails.git
ARG USERDETAILS_BRANCH=master

WORKDIR /build

# Clone and checkout specific version/branch
RUN git clone ${USERDETAILS_REPO} . && \
    if [ "${USERDETAILS_BRANCH}" != "master" ]; then \
        git checkout ${USERDETAILS_BRANCH}; \
    fi && \
    if [ "${USERDETAILS_VERSION}" != "develop" ]; then \
        git checkout ${USERDETAILS_VERSION} || git checkout tags/v${USERDETAILS_VERSION} || true; \
    fi

# Build the WAR file
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew clean war -x test --no-daemon

# ============================================
# Stage 2: Runtime
# ============================================
FROM ${RUNTIME_IMAGE}

LABEL org.opencontainers.image.title="ALA Userdetails"
LABEL org.opencontainers.image.description="Atlas of Living Australia User Details Service"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/userdetails"

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

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR from builder
COPY --from=builder /build/build/libs/*.war /usr/local/tomcat/webapps/userdetails.war

# Set config location
ENV CATALINA_OPTS="-Duserdetails.config=file:/data/userdetails/config/userdetails-config.properties"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl --fail http://localhost:8080/userdetails/ || exit 1

# Start with dockerize
ENTRYPOINT ["sh", "-c", "exec dockerize ${DOCKERIZE_OPTS} catalina.sh run"]

