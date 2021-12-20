#!/bin/bash
export FILE="ecodata-$(date +%y%m%d).tgz"
echo "Copying file $FILE"

mkdir -p /data/backups/prod
cd /data/backups/prod
scp {{ecodata_backup_user}}@ala-beyonce.it.csiro.au:/data/backups/$FILE .
