#!/bin/bash
# MySQL initialization script for Collectory database
# This runs automatically when MySQL container starts for the first time

set -e

echo "🔧 Initializing Collectory database..."

# Create additional databases if needed
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    -- Collectory database is already created by MYSQL_DATABASE env var
    -- Just grant additional permissions if needed
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;

    -- Create tables (if using Liquibase/Flyway, this is handled by the app)
    -- Otherwise, you can add schema here:

    USE ${MYSQL_DATABASE};

    -- Basic schema for collectory (minimal for POC)
    -- In production, this should be managed by migrations

    SELECT 'Collectory database initialized!' as status;
EOSQL

echo "✅ Collectory database ready!"

