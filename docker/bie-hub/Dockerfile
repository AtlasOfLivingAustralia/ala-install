# syntax=docker/dockerfile:1.4
# bie-hub - BIE Hub - Species information
# AUTO-GENERATED - DO NOT EDIT MANUALLY
# Edit docker-common/defaults/main.yml and re-run ansible

ARG GRADLE_BUILDER_IMAGE=gradle-builder:jdk17
ARG RUNTIME_IMAGE=tomcat:9-jre17

# ============================================
# Stage 1: Build (try Nexus first, then source)
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG VERSION=6.0.0
ARG REPO=https://github.com/AtlasOfLivingAustralia/bie-hub.git
ARG BRANCH=master
ARG ARTIFACT=bie-hub
ARG GROUP_ID=au.org.ala
ARG NEXUS_BASE=https://nexus.ala.org.au/service/local/artifact/maven/redirect

WORKDIR /build

# Try Nexus first (if version is release tag), fallback to source build
RUN echo "🔍 Checking Nexus for ${ARTIFACT} ${VERSION}..." && \
    if [ "${VERSION}" != "develop" ] && [ "${VERSION}" != "master" ]; then \
        NEXUS_URL="${NEXUS_BASE}?r=public&g=${GROUP_ID}&a=${ARTIFACT}&v=${VERSION}&e=war" && \
        if curl -f -L -o artifact.war "${NEXUS_URL}"; then \
            echo "✅ Downloaded from Nexus"; \
        else \
            echo "⚠️  Building from source..." && \
            git clone ${REPO} . && \
            git checkout ${VERSION} || git checkout tags/v${VERSION} || git checkout ${BRANCH} && \
            ./gradlew clean war -x test --no-daemon --max-workers=1 && \
            mv build/libs/*.war artifact.war; \
        fi; \
    else \
        git clone ${REPO} . && \
        git checkout ${BRANCH} && \
        ./gradlew clean war -x test --no-daemon --max-workers=1 && \
        mv build/libs/*.war artifact.war; \
    fi

# ============================================
# Stage 2: Runtime
# ============================================
FROM tomcat:9-jre17

LABEL org.opencontainers.image.title="bie-hub"
LABEL org.opencontainers.image.description="BIE Hub - Species information"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/bie-hub.git"

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Setup
RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=builder /build/artifact.war /usr/local/tomcat/webapps/bie-hub.war

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl -f http://localhost:8080/bie-hub/actuator/health || exit 1

EXPOSE 8080

CMD ["catalina.sh", "run"]

