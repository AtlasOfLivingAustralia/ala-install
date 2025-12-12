#!/bin/bash
# MongoDB initialization script for CAS
# Creates CAS database and users

set -e

echo "Initializing MongoDB for CAS..."

# Create CAS database and user
mongosh --quiet <<EOF
use ${MONGO_INITDB_DATABASE}

db.createUser({
  user: 'cas',
  pwd: '${CAS_MONGO_PASSWORD:-changeme}',
  roles: [
    {
      role: 'readWrite',
      db: '${MONGO_INITDB_DATABASE}'
    }
  ]
});

// Create collections for CAS
db.createCollection('casTickets');
db.createCollection('casSessions');
db.createCollection('casAudit');
db.createCollection('casServices');

print("MongoDB initialization completed for CAS");
EOF

echo "✅ MongoDB initialized for CAS"

