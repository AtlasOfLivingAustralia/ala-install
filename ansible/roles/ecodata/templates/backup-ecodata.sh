#!/bin/bash
cd {{data_dir}}
mkdir -p {{data_dir}}/backups
mongodump -d ecodata -u {{ ecodata_username }} -p {{ ecodata_password }}
tar zcvf {{data_dir}}/backups/ecodata-$(date +%y%m%d).tgz /data/dump {{data_dir}}/ecodata/models

