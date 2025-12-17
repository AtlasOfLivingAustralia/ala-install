# syntax=docker/dockerfile:1.4
# ALA API Key Service
# Multi-stage build: gradle-builder -> runtime

ARG GRADLE_BUILDER_IMAGE=gradle:7-jdk11-jammy
ARG RUNTIME_IMAGE=tomcat:9-jre11

# ============================================
# Stage 1: Build (try Nexus first, then source)
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG APIKEY_VERSION=1.7.0
ARG APIKEY_REPO=https://github.com/AtlasOfLivingAustralia/apikey.git
ARG APIKEY_BRANCH=master
ARG APIKEY_ARTIFACT=apikey
ARG APIKEY_GROUP_ID=au.org.ala
ARG APIKEY_CLASSIFIER=exec
ARG NEXUS_BASE=https://nexus.ala.org.au/service/local/artifact/maven/redirect

WORKDIR /build

# Strategy: Try to download pre-built artifact from Nexus first
# Using Maven redirect service with classifier=exec
RUN echo "🔍 Checking Nexus for ${APIKEY_ARTIFACT} ${APIKEY_VERSION}..." && \
    if [ "${APIKEY_VERSION}" != "develop" ] && [ "${APIKEY_VERSION}" != "master" ]; then \
        NEXUS_URL="${NEXUS_BASE}?r=public&g=${APIKEY_GROUP_ID}&a=${APIKEY_ARTIFACT}&v=${APIKEY_VERSION}&e=war&c=${APIKEY_CLASSIFIER}" && \
        echo "   Trying: ${NEXUS_URL}" && \
        if curl -f -L -o apikey.war "${NEXUS_URL}"; then \
            echo "✅ Downloaded from Nexus in seconds (skipping 5-10 min build)"; \
        else \
            echo "⚠️  Not found in Nexus, building from source..." && \
            git clone ${APIKEY_REPO} . && \
            (git checkout ${APIKEY_VERSION} || git checkout tags/v${APIKEY_VERSION} || git checkout ${APIKEY_BRANCH}) && \
            export GRADLE_OPTS="-Dorg.gradle.internal.http.connectionTimeout=300000 -Dorg.gradle.internal.http.socketTimeout=300000 -Dorg.gradle.internal.http.totaltimeout=1800000" && \
            ./gradlew clean war -x test --no-daemon --max-workers=1 && \
            mv build/libs/*.war apikey.war && \
            echo "✅ Built from source"; \
        fi; \
    else \
        echo "⚠️  Version is ${APIKEY_VERSION}, building from source..." && \
        git clone ${APIKEY_REPO} . && \
        git checkout ${APIKEY_BRANCH} && \
        export GRADLE_OPTS="-Dorg.gradle.internal.http.connectionTimeout=300000 -Dorg.gradle.internal.http.socketTimeout=300000 -Dorg.gradle.internal.http.totaltimeout=1800000" && \
        ./gradlew clean war -x test --no-daemon --max-workers=1 && \
        mv build/libs/*.war apikey.war && \
        echo "✅ Built from source"; \
    fi

# ============================================
# Stage 2: Runtime
# ============================================
FROM ${RUNTIME_IMAGE}

LABEL org.opencontainers.image.title="ALA API Key"
LABEL org.opencontainers.image.description="Atlas of Living Australia API Key Service"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/apikey"

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

# Copy built WAR from builder (standardized name from Nexus or source build)
COPY --from=builder /build/apikey.war /usr/local/tomcat/webapps/apikey.war

# Set config location
ENV CATALINA_OPTS="-Dapikey.config=file:/data/apikey/config/apikey-config.properties"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl --fail http://localhost:8080/apikey/ || exit 1

# Start with dockerize
ENTRYPOINT ["sh", "-c", "exec dockerize ${DOCKERIZE_OPTS} catalina.sh run"]

