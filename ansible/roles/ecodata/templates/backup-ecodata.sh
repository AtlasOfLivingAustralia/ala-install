#!/bin/bash

mkdir -p {{data_dir}}/backups/daily
mkdir -p {{data_dir}}/backups/weekly
mkdir -p {{data_dir}}/backups/monthly
mkdir -p {{data_dir}}/backups/audit

cd {{data_dir}}/backups
mongodump -d ecodata -u {{ ecodata_username }} -p {{ ecodata_password }}

mv {{data_dir}}/backups/dump/ecodata/auditMessage.* {{data_dir}}/backups/audit/

tar zcvf {{data_dir}}/backups/daily/ecodata-$(date +%y%m%d).tgz {{data_dir}}/backups/dump {{data_dir}}/ecodata/models

# copy a backup to the weekly dir every sunday
if [ $(date +%u) -eq 0 ]; then
  cp {{data_dir}}/backups/daily/ecodata-$(date +%y%m%d).tgz {{data_dir}}/backups/weekly
fi

# copy a backup to the monthly dir on the 1st of every month
if [ $(date +%d) -eq 1 ]; then
  cp {{data_dir}}/backups/daily/ecodata-$(date +%y%m%d).tgz {{data_dir}}/backups/monthly
fi


#only keep a week of dailys
find {{data_dir}}/backups/daily -mtime +7 -delete

# keep a month of weeklys
find {{data_dir}}/backups/weekly -mtime +30 -delete

# and 6 months of monthlys
find {{data_dir}}/backups/monthly -mtime +180 -delete
