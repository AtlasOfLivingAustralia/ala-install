# syntax=docker/dockerfile:1.4
# ALA Collectory Service
# Multi-stage build: gradle-builder -> runtime

ARG GRADLE_BUILDER_IMAGE=gradle-builder:jdk17
ARG RUNTIME_IMAGE=tomcat:9-jre17

# ============================================
# Stage 1: Build (try Nexus first, then source)
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG COLLECTORY_VERSION=6.0.0
ARG COLLECTORY_REPO=https://github.com/AtlasOfLivingAustralia/collectory.git
ARG COLLECTORY_BRANCH=develop
ARG COLLECTORY_ARTIFACT=generic-collectory
ARG COLLECTORY_GROUP_ID=au.org.ala
ARG NEXUS_BASE=https://nexus.ala.org.au/service/local/artifact/maven/redirect

WORKDIR /build

# Strategy: Try to download pre-built artifact from Nexus first
# Using Maven redirect service (not direct repository path)
RUN echo "🔍 Checking Nexus for ${COLLECTORY_ARTIFACT} ${COLLECTORY_VERSION}..." && \
    if [ "${COLLECTORY_VERSION}" != "develop" ] && [ "${COLLECTORY_VERSION}" != "master" ]; then \
        NEXUS_URL="${NEXUS_BASE}?r=public&g=${COLLECTORY_GROUP_ID}&a=${COLLECTORY_ARTIFACT}&v=${COLLECTORY_VERSION}&e=war" && \
        echo "   Trying: ${NEXUS_URL}" && \
        if curl -f -L -o collectory.war "${NEXUS_URL}"; then \
            echo "✅ Downloaded from Nexus in seconds (skipping 5-10 min build)"; \
        else \
            echo "⚠️  Not found in Nexus, building from source..." && \
            git clone ${COLLECTORY_REPO} . && \
            (git checkout ${COLLECTORY_VERSION} || git checkout tags/v${COLLECTORY_VERSION} || git checkout ${COLLECTORY_BRANCH}) && \
            export GRADLE_OPTS="-Dorg.gradle.internal.http.connectionTimeout=300000 -Dorg.gradle.internal.http.socketTimeout=300000 -Dorg.gradle.internal.http.totaltimeout=1800000" && \
            ./gradlew clean war -x test --no-daemon --max-workers=1 && \
            mv build/libs/*.war collectory.war && \
            echo "✅ Built from source"; \
        fi; \
    else \
        echo "⚠️  Version is ${COLLECTORY_VERSION}, building from source..." && \
        git clone ${COLLECTORY_REPO} . && \
        git checkout ${COLLECTORY_BRANCH} && \
        export GRADLE_OPTS="-Dorg.gradle.internal.http.connectionTimeout=300000 -Dorg.gradle.internal.http.socketTimeout=300000 -Dorg.gradle.internal.http.totaltimeout=1800000" && \
        ./gradlew clean war -x test --no-daemon --max-workers=1 && \
        mv build/libs/*.war collectory.war && \
        echo "✅ Built from source"; \
    fi

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

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR from builder (standardized name from Nexus or source build)
COPY --from=builder /build/collectory.war /usr/local/tomcat/webapps/collectory.war

# Set config location
ENV CATALINA_OPTS="-Dcollectory.config=file:/data/collectory/config/collectory-config.properties"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl --fail http://localhost:8080/collectory/actuator/health || exit 1

# Start with dockerize
ENTRYPOINT ["sh", "-c", "exec dockerize ${DOCKERIZE_OPTS} catalina.sh run"]

