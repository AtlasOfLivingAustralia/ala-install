# syntax=docker/dockerfile:1.4
# dashboard - Dashboard - Portal statistics
# AUTO-GENERATED - DO NOT EDIT MANUALLY
# Edit docker-common/defaults/main.yml and re-run ansible

ARG GRADLE_BUILDER_IMAGE=gradle-builder:jdk11
ARG RUNTIME_IMAGE=tomcat:9-jre11

# ============================================
# Stage 1: Build (try Nexus first, then source)
# ============================================
FROM ${GRADLE_BUILDER_IMAGE} AS builder

ARG VERSION=6.0.0
ARG REPO=https://github.com/AtlasOfLivingAustralia/dashboard.git
ARG BRANCH=master
ARG ARTIFACT=dashboard
ARG GROUP_ID=au.org.ala
# Format: https://nexus.ala.org.au/repository/releases/au/org/ala/{artifact}/{version}/{artifact}-{version}{classifier}.war

WORKDIR /build

# Try Nexus first (if version is release tag), fail if not found
RUN echo "🔍 Checking Nexus for ${ARTIFACT} ${VERSION}..." && \
    if [ "${VERSION}" != "develop" ] && [ "${VERSION}" != "master" ]; then \
        NEXUS_URL="https://nexus.ala.org.au/repository/releases/au/org/ala/${ARTIFACT}/${VERSION}/${ARTIFACT}-${VERSION}.war" && \
        echo "   📥 Trying: ${NEXUS_URL}" && \
        if curl -f -L -o artifact.war "${NEXUS_URL}"; then \
            echo "✅ Downloaded from Nexus"; \
        else \
            echo "❌ ERROR: Artifact not found in Nexus at ${NEXUS_URL}"; \
            echo "    Please verify:"; \
            echo "    1. ARTIFACT=${ARTIFACT} is correct"; \
            echo "    2. VERSION=${VERSION} exists in Nexus"; \
            echo "    3. CLASSIFIER=${CLASSIFIER} is correct (if applicable)"; \
            exit 1; \
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
FROM tomcat:9-jre11

LABEL org.opencontainers.image.title="dashboard"
LABEL org.opencontainers.image.description="Dashboard - Portal statistics"
LABEL org.opencontainers.image.source="https://github.com/AtlasOfLivingAustralia/dashboard.git"

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Setup
RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=builder /build/artifact.war /usr/local/tomcat/webapps/dashboard.war

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl -f http://localhost:8080/dashboard/actuator/health || exit 1

EXPOSE 8080

CMD ["catalina.sh", "run"]

