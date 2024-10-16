#!/bin/bash
if [ $1 = "start" ]; then
  docker-compose -f /data/ala-sensitive-data-service.yml up -d
else
  docker-compose -f /data/ala-sensitive-data-service.yml kill
fi