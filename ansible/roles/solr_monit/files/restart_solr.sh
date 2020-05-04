#!/bin/bash

set -x

solr_process_id=$(/usr/bin/pgrep -l -u solr | /bin/grep java | /usr/bin/cut -f 1 -d ' ')

echo "solr_process_id=${solr_process_id}"

# Check if there was a solr process id found by that process
if [[ -z "${solr_process_id}" ]];
  then
    echo "Did not find a solr process"
else
    echo "Attempting to kill ${solr_process_id} with signal 15"
    /bin/kill -s 15 "${solr_process_id}"
    sleep 5
    echo "Attempting to kill ${solr_process_id} with signal 9"
    /bin/kill -s 9 "${solr_process_id}"
    sleep 5
fi

echo "Restarting the solr service"
/usr/sbin/service solr restart
