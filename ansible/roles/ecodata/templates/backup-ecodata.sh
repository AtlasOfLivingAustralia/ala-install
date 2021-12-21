#!/bin/bash
mkdir -p {{data_dir}}/backups
cd {{data_dir}}/backups
mongodump -d ecodata -u {{ ecodata_username }} -p {{ ecodata_password }}
tar zcvf {{data_dir}}/backups/ecodata-$(date +%y%m%d).tgz {{data_dir}}/backups/dump {{data_dir}}/ecodata/models

