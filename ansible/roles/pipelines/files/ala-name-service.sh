#!/bin/bash
if [ $1 = "start" ]; then
  echo 'Starting name service'
  docker-compose -f /data/ala-name-service.yml up -d
else
  echo 'shutting down name service'
  docker-compose -f /data/ala-name-service.yml kill
fi