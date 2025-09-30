#!/bin/bash
echo "Remember to stop mongo on the mongo replica server, and delete the contents of the database"
export FILE="ecodata-$(date +%y%m%d).tgz"

cd /data/backups/prod
tar -xf $FILE
# audit messages are stored outside the tar
mv ./audit/auditMessage.* ./data/backups/dump/ecodata/
cp ./data/ecodata/models/* /data/ecodata/models/
chown ecodata:ecodata /data/ecodata/models/*

mongorestore --drop -d ecodata -u {{ ecodata_username }} -p {{ ecodata_password }} ./data/backups/dump/ecodata

mongosh -u {{ ecodata_username }} -p {{ ecodata_password }} ecodata --eval 'db.setting.update({key:"meritfielddata.announcement.text"},{$set:{value:"This is the MERIT staging environment"}})';

# clean up as we are tight on disk space and the audit messages are > 50GB
mv ./data/backups/dump/ecodata/auditMessage.* ./audit/
rm -r /data/backups/prod/data

# Run any release tagged data migration scripts
ECODATA_VERSION={{ ecodata_version }}
ECODATA_NUMERIC_VERSION=${ECODATA_VERSION%%'-SNAPSHOT'*}

SCRIPT_DIR=/data/ecodata/scripts/releases/$ECODATA_NUMERIC_VERSION
cd $SCRIPT_DIR
DATA_MIGRATION_FILE=release$ECODATA_NUMERIC_VERSION.sh

if [[ -f "$DATA_MIGRATION_FILE" ]]
then
  chmod u+x $DATA_MIGRATION_FILE
  ./$DATA_MIGRATION_FILE {{ ecodata_password }}
fi

echo "Restore complete.  Delete the data from the mongo replica and re-start mongo so it can resync"
