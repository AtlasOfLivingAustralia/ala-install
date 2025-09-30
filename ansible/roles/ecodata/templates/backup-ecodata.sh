#!/bin/bash

su - {{ecodata_backup_user}}

mkdir -p {{data_dir}}/backups/daily
mkdir -p {{data_dir}}/backups/weekly
mkdir -p {{data_dir}}/backups/monthly
mkdir -p {{data_dir}}/backups/yearly
mkdir -p {{data_dir}}/backups/audit

cd {{data_dir}}/backups
mongodump -d ecodata -u {{ ecodata_username }} -p {{ ecodata_password }}

mv {{data_dir}}/backups/dump/ecodata/auditMessage.* {{data_dir}}/backups/audit/

tar zcvf {{data_dir}}/backups/daily/ecodata-$(date +%y%m%d).tgz {{data_dir}}/backups/dump {{data_dir}}/ecodata/models

# copy a backup to the weekly dir every sunday
if [ $(date +%u) -eq 1 ]; then
  cp {{data_dir}}/backups/daily/ecodata-$(date +%y%m%d).tgz {{data_dir}}/backups/weekly
fi

# copy a backup to the monthly dir on the 1st of every month
if [ $(date +%d) -eq 1 ]; then
  cp {{data_dir}}/backups/daily/ecodata-$(date +%y%m%d).tgz {{data_dir}}/backups/monthly
fi

#copy a backup to the yearly dir on the 1st of Jan every year
if [ $(date +%j) -eq 1 ]; then
  cp {{data_dir}}/backups/daily/ecodata-$(date +%y%m%d).tgz {{data_dir}}/backups/yearly
fi

# only keep 2 weeks of dailys
find {{data_dir}}/backups/daily -mtime +14 -delete

# keep a month of weeklys
find {{data_dir}}/backups/weekly -mtime +30 -delete

# and 2 years of monthlys
find {{data_dir}}/backups/monthly -mtime +730 -delete

# Remove the dump directory to save space and prevent it being backed up to s3
rm -r {{data_dir}}/backups/dump

{% if mongo_backup_bucket is defined %}

cd {{data_dir}}/backups
aws s3 sync . s3://{{mongo_backup_bucket}}/

{% endif %}

#exit


{% if document_backup_bucket is defined %}
# This is temporary until we make s3 the primary document storage mechanism
#su - {{ecodata_user}}

cd {{data_dir}}/ecodata/uploads
aws s3 sync . s3://{{document_backup_bucket}}/

exit

{% endif %}



