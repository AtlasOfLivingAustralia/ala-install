# syntax=docker/dockerfile:1.4
# ALA CAS 5/6 Server
# Multi-stage build: maven-builder -> runtime

ARG MAVEN_BUILDER_IMAGE=maven:3.8-eclipse-temurin-11
ARG RUNTIME_IMAGE=eclipse-temurin:11-jre-jammy

# ============================================
# Stage 1: Build (try Nexus first, then source)
# ============================================
FROM ${MAVEN_BUILDER_IMAGE} AS builder

ARG CAS_VERSION=6.5.6-3
ARG CAS_REPO=https://github.com/AtlasOfLivingAustralia/ala-cas-5.git
ARG CAS_BRANCH=master
ARG CAS_ARTIFACT=cas
ARG CAS_GROUP_ID=au.org.ala
ARG CAS_CLASSIFIER=exec
ARG NEXUS_BASE=https://nexus.ala.org.au/service/local/artifact/maven/redirect

WORKDIR /build

# Strategy: Try to download pre-built artifact from Nexus first
# Using Maven redirect service (not direct repository path)
RUN echo "🔍 Checking Nexus for ${CAS_ARTIFACT} ${CAS_VERSION}..." && \
    if [ "${CAS_VERSION}" != "develop" ] && [ "${CAS_VERSION}" != "master" ]; then \
        NEXUS_URL="${NEXUS_BASE}?r=public&g=${CAS_GROUP_ID}&a=${CAS_ARTIFACT}&v=${CAS_VERSION}&e=war&c=${CAS_CLASSIFIER}" && \
        echo "   Trying: ${NEXUS_URL}" && \
        if curl -f -L -o ala-cas.war "${NEXUS_URL}"; then \
            echo "✅ Downloaded from Nexus in seconds (skipping 25-35 min build)"; \
        else \
            echo "⚠️  Not found in Nexus, building from source..." && \
            git clone ${CAS_REPO} . && \
            (git checkout ${CAS_VERSION} || git checkout tags/v${CAS_VERSION} || git checkout ${CAS_BRANCH}) && \
            export MAVEN_OPTS="-Dmaven.wagon.http.connectionTimeout=120000 -Dmaven.wagon.http.readTimeout=120000" && \
            echo "🔨 Building CAS with Maven..." && \
            mvn clean package -DskipTests -q -T 1C -Dmaven.wagon.http.retryHandler.count=3 && \
            mv target/*.war ala-cas.war && \
            echo "✅ CAS built from source"; \
        fi; \
    else \
        echo "⚠️  Version is ${CAS_VERSION}, building from source..." && \
        git clone ${CAS_REPO} . && \
        git checkout ${CAS_BRANCH} && \
        export MAVEN_OPTS="-Dmaven.wagon.http.connectionTimeout=120000 -Dmaven.wagon.http.readTimeout=120000" && \
        echo "🔨 Building CAS with Maven..." && \
        mvn clean package -DskipTests -q -T 1C -Dmaven.wagon.http.retryHandler.count=3 && \
        mv target/*.war ala-cas.war && \
        echo "✅ CAS built from source"; \
    fi

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

# Copy built WAR from builder (standardized name from Nexus or Maven build)
COPY --from=builder /build/ala-cas.war ./cas.war

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

