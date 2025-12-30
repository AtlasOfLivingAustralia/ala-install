# syntax=docker/dockerfile:1.4
# Gatus Health Dashboard
# Lightweight monitoring solution for Living Atlas services

FROM twinproduction/gatus:stable

LABEL org.opencontainers.image.title="Gatus Health Dashboard"
LABEL org.opencontainers.image.description="Atlas of Living Australia Health Monitoring"
LABEL org.opencontainers.image.source="https://github.com/TwiN/gatus"

# Create data directory
RUN mkdir -p /data

# Set working directory
WORKDIR /data

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# Default command (inherited from base image)
# CMD ["/gatus"]

