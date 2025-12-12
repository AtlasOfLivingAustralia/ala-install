# syntax=docker/dockerfile:1.14.0
# Gradle Builder Base Image for Living Atlas
# Based on INBO pattern but adapted for ALA
# Uses Eclipse Temurin (generic, cloud-agnostic)

ARG BUILDPLATFORM=linux/amd64
ARG GRADLE_VERSION=7
ARG JDK_VERSION=11

# CRITICAL: Use -jammy variant (Ubuntu) instead of -corretto (Amazon Linux)
# This makes it cloud-agnostic and avoids AWS dependencies
FROM --platform=${BUILDPLATFORM} gradle:${GRADLE_VERSION}-jdk${JDK_VERSION}-jammy AS builder
COPY gradle.properties /home/gradle/.gradle/gradle.properties
COPY init.gradle /home/gradle/.gradle/init.gradle

# Environment for read-only dependency cache
ENV GRADLE_RO_DEP_CACHE=/gradle-cache

# Install common build tools
# This cache is mounted as a volume from gradle-deps-cache
# and shared across all builds for better performance
RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        rsync \
        curl \
        wget \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download OpenTelemetry agent (for runtime images)
RUN mkdir -p /opt/opentelemetry-agent && \
    curl -fL https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.21.0/opentelemetry-javaagent.jar \
         -o /opt/opentelemetry-agent/opentelemetry-javaagent.jar

# Working directory for builds
WORKDIR /build

# This is a builder image, no CMD needed

