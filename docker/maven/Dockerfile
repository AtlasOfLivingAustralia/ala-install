# syntax=docker/dockerfile:1.14.0
# Maven Builder Base Image for Living Atlas
# Based on Gradle builder pattern but adapted for Maven
# Uses Eclipse Temurin (generic, cloud-agnostic)

ARG BUILDPLATFORM=linux/amd64
ARG MAVEN_VERSION=3.9
ARG JDK_VERSION=11

# Use Maven with Eclipse Temurin JDK
# Available tags: maven:3.9-eclipse-temurin-11, maven:3.9-eclipse-temurin-17, maven:3.9-eclipse-temurin-21
FROM --platform=${BUILDPLATFORM} maven:${MAVEN_VERSION}-eclipse-temurin-${JDK_VERSION}

# Install common build tools
# Docker BuildKit cache is used with --mount=type=cache in RUN commands
# This provides shared caching across builds without needing external volumes
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

# This is a builder image - used as base for multi-stage builds


