#!/bin/bash
# MySQL initialization script for Species List database

set -e

echo "🔧 Initializing Species List database..."

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    -- Create species-list database
    CREATE DATABASE IF NOT EXISTS specieslist DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

    -- Create user
    CREATE USER IF NOT EXISTS 'specieslist'@'%' IDENTIFIED BY '${SPECIESLIST_MYSQL_PASSWORD:-changeme}';

    -- Grant permissions
    GRANT ALL PRIVILEGES ON specieslist.* TO 'specieslist'@'%';

    -- Allow collectory user to access species-list database (for integration)
    GRANT SELECT ON specieslist.* TO '${MYSQL_USER}'@'%';

    FLUSH PRIVILEGES;

    SELECT 'Species List database initialized!' as status;
EOSQL

echo "✅ Species List database ready!"

