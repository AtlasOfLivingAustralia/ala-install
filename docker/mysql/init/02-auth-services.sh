#!/bin/bash
# MySQL initialization script for CAS authentication services
# Creates databases for: CAS, userdetails, apikey

set -e

echo "🔧 Initializing CAS authentication databases..."

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    -- Create databases
    CREATE DATABASE IF NOT EXISTS cas DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE DATABASE IF NOT EXISTS userdetails DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE DATABASE IF NOT EXISTS apikey DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

    -- Create users (reusing collectory user for simplicity, or create dedicated users)
    CREATE USER IF NOT EXISTS 'cas'@'%' IDENTIFIED BY '${CAS_MYSQL_PASSWORD:-changeme}';
    CREATE USER IF NOT EXISTS 'userdetails'@'%' IDENTIFIED BY '${USERDETAILS_MYSQL_PASSWORD:-changeme}';
    CREATE USER IF NOT EXISTS 'apikey'@'%' IDENTIFIED BY '${APIKEY_MYSQL_PASSWORD:-changeme}';

    -- Grant permissions
    GRANT ALL PRIVILEGES ON cas.* TO 'cas'@'%';
    GRANT ALL PRIVILEGES ON userdetails.* TO 'userdetails'@'%';
    GRANT ALL PRIVILEGES ON apikey.* TO 'apikey'@'%';

    -- Allow collectory user to access cas databases (for CAS integration)
    GRANT SELECT ON cas.* TO '${MYSQL_USER}'@'%';
    GRANT SELECT ON userdetails.* TO '${MYSQL_USER}'@'%';

    FLUSH PRIVILEGES;

    SELECT 'CAS authentication databases initialized!' as status;
EOSQL

echo "✅ CAS, userdetails, and apikey databases ready!"

