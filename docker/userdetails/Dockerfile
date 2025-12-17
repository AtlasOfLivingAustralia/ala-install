# syntax=docker/dockerfile:1.4
# ALA Userdetails Service
# Multi-stage build: gradle-builder -> runtime

ARG GRADLE_BUILDER_IMAGE=gradle:7-jdk11-jammy
ARG RUNTIME_IMAGE=tomcat:9-jre11

# ============================================
# Stage 1: Build (try Nexus first, then source)
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG USERDETAILS_VERSION=3.2.1
ARG USERDETAILS_REPO=https://github.com/AtlasOfLivingAustralia/userdetails.git
ARG USERDETAILS_BRANCH=master
ARG USERDETAILS_ARTIFACT=userdetails
ARG USERDETAILS_GROUP_ID=au.org.ala
ARG USERDETAILS_CLASSIFIER=exec
ARG NEXUS_BASE=https://nexus.ala.org.au/service/local/artifact/maven/redirect

WORKDIR /build

# Using Maven redirect service with classifier=exec
RUN echo "🔍 Checking Nexus for ${USERDETAILS_ARTIFACT} ${USERDETAILS_VERSION}..." && \
    if [ "${USERDETAILS_VERSION}" != "develop" ] && [ "${USERDETAILS_VERSION}" != "master" ]; then \
        NEXUS_URL="${NEXUS_BASE}?r=public&g=${USERDETAILS_GROUP_ID}&a=${USERDETAILS_ARTIFACT}&v=${USERDETAILS_VERSION}&e=war&c=${USERDETAILS_CLASSIFIER}" && \
        echo "   Trying: ${NEXUS_URL}" && \
        if curl -f -L -o userdetails.war "${NEXUS_URL}"; then \
            echo "✅ Downloaded from Nexus in seconds"; \
        else \
            echo "⚠️  Not found in Nexus, building from source..." && \
            git clone ${USERDETAILS_REPO} . && \
            (git checkout ${USERDETAILS_VERSION} || git checkout tags/v${USERDETAILS_VERSION} || git checkout ${USERDETAILS_BRANCH}) && \
            export GRADLE_OPTS="-Dorg.gradle.internal.http.connectionTimeout=300000 -Dorg.gradle.internal.http.socketTimeout=300000 -Dorg.gradle.internal.http.totaltimeout=1800000" && \
            ./gradlew clean war -x test --no-daemon --max-workers=1 && \
            mv build/libs/*.war userdetails.war && \
            echo "✅ Built from source"; \
        fi; \
    else \
        echo "⚠️  Building from source..." && \
        git clone ${USERDETAILS_REPO} . && \
        git checkout ${USERDETAILS_BRANCH} && \
        export GRADLE_OPTS="-Dorg.gradle.internal.http.connectionTimeout=300000 -Dorg.gradle.internal.http.socketTimeout=300000 -Dorg.gradle.internal.http.totaltimeout=1800000" && \
        ./gradlew clean war -x test --no-daemon --max-workers=1 && \
        mv build/libs/*.war userdetails.war && \
        echo "✅ Built from source"; \
    fi

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

# Copy built WAR from builder (standardized name from Nexus or source build)
COPY --from=builder /build/userdetails.war /usr/local/tomcat/webapps/userdetails.war

# Set config location
ENV CATALINA_OPTS="-Duserdetails.config=file:/data/userdetails/config/userdetails-config.properties"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl --fail http://localhost:8080/userdetails/ || exit 1

# Start with dockerize
ENTRYPOINT ["sh", "-c", "exec dockerize ${DOCKERIZE_OPTS} catalina.sh run"]

