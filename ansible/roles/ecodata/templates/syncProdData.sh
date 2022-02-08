#!/bin/bash
echo "Remember to stop monogo on the mongo replica server, and delete the contents of the database"
export FILE="ecodata-$(date +%y%m%d).tgz"

cd /data/backups/prod
tar -xf $FILE
mongorestore --drop -d ecodata -u {{ ecodata_username }} -p {{ ecodata_password }} ./data/backups/dump/ecodata

mongo -u {{ ecodata_username }} -p {{ ecodata_password }} ecodata --eval 'db.setting.update({key:"meritfielddata.announcement.text"},{$set:{value:"This is the MERIT staging environment"}})';

echo "Restore complete.  Delete the data from the mongo replica and re-start mongo so it can resync"
