#!bin/sh

#
# Delete temporary files that are older than 7 days
#
sudo find /data/profile-hub/temp -type f -mtime +7 -exec rm {} +
