#!/bin/bash
# Auto-generated entrypoint for alerts
# Ensures proper permissions and executes the service
#
# Environment variables:
#   DEBUG_ENTRYPOINT=1    Keep container alive on errors (drops to shell instead of exiting)

SERVICE_USER="alerts"
APP_ARTIFACT="alerts"
DEBUG_MODE="${DEBUG_ENTRYPOINT:-0}"

echo "🔍 Checking permissions for /data/${APP_ARTIFACT}..."
[ "${DEBUG_MODE}" = "1" ] && echo "   (DEBUG MODE ENABLED)"

# Fix ownership of config directory if it exists and is owned by root
if [ -d "/data/${APP_ARTIFACT}/config" ]; then
    if [ "$(stat -c '%U' /data/${APP_ARTIFACT}/config)" = "root" ]; then
        echo "⚙️  Fixing config directory ownership..."
        chown -R ${SERVICE_USER}:${SERVICE_USER} /data/${APP_ARTIFACT}/config || true
    fi
fi

# Fix ownership of data directory if it exists and is owned by root
if [ -d "/data/${APP_ARTIFACT}/data" ]; then
    if [ "$(stat -c '%U' /data/${APP_ARTIFACT}/data)" = "root" ]; then
        echo "⚙️  Fixing data directory ownership..."
        chown -R ${SERVICE_USER}:${SERVICE_USER} /data/${APP_ARTIFACT}/data || true
    fi
fi

# Fix ownership of /app/app.war if it exists and is owned by root
if [ -f "/app/app.war" ]; then
    if [ "$(stat -c '%U' /app/app.war)" = "root" ]; then
        echo "⚙️  Fixing /app/app.war ownership..."
        chown ${SERVICE_USER}:${SERVICE_USER} /app/app.war || true
    fi
fi

# Fix ownership of /usr/local/tomcat/webapps if it exists and is owned by root
if [ -d "/usr/local/tomcat/webapps" ]; then
    if [ "$(stat -c '%U' /usr/local/tomcat/webapps)" = "root" ]; then
        echo "⚙️  Fixing /usr/local/tomcat/webapps ownership..."
        chown -R ${SERVICE_USER}:${SERVICE_USER} /usr/local/tomcat/webapps || true
    fi
fi

echo "✅ Permission check completed"
echo "🚀 Starting alerts as user: ${SERVICE_USER}"
echo ""

# Debug: Show environment
if [ "${DEBUG_MODE}" = "1" ] || [ "${DEBUG_MODE}" = "true" ]; then
    echo "📋 Environment variables:"
    echo "   USER=$(id -un)"
    echo "   JAVA_OPTS=${JAVA_OPTS}"
    echo "   PATH=${PATH}"
    echo ""
    echo "📋 Executing command: $@"
    echo "---"
    echo ""
fi

# Execute the CMD - if it fails in DEBUG mode, drop to shell
if [ "${DEBUG_MODE}" = "1" ] || [ "${DEBUG_MODE}" = "true" ]; then
    # In debug mode, try to run and stay alive if it fails
    "$@"
    EXIT_CODE=$?

    if [ ${EXIT_CODE} -ne 0 ]; then
        echo ""
        echo "❌ Service exited with code: ${EXIT_CODE}"
        echo "🔍 DEBUG MODE ACTIVE - Dropping to shell for investigation..."
        echo "💡 Tip: Use 'exit' to leave the shell"
        echo ""
        /bin/bash
        exit ${EXIT_CODE}
    fi
else
    # Normal mode: just exec and let it fail normally
    exec "$@"
fi

