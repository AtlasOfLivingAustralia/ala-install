#!/bin/bash
export FILE="ecodata-$(date +%y%m%d).tgz"
echo "Copying file $FILE"

mkdir -p /data/backups/prod
mkdir -p /data/backups/prod/audit
cd /data/backups/prod
scp {{ecodata_backup_user}}@{{production_server_hostname}}:/data/backups/daily/$FILE .
scp {{ecodata_backup_user}}@{{production_server_hostname}}:/data/backups/audit/auditMessage.* ./audit/


