#!/bin/bash
export USER={{ecodata_backup_user}}
export ECODATA_USER={{ecodata_user}}


cd /data/ecodata/uploads
su {{ecodata_user}} -c 'rsync -av {{production_server_hostname}}:/data/ecodata/uploads/ .'
sudo chown -R $ECODATA_USER:$ECODATA_USER .

cd /data/ecodata/models
su {{ecodata_user}} -c 'rsync -av {{production_server_hostname}}:/data/ecodata/models/ .'
sudo chown -R $ECODATA_USER:$ECODATA_USER .