#!/bin/bash
if [ $1 = "start" ]; then
  docker-compose -f /data/graphql-service.yml up -d
else
  docker-compose -f /data/graphql-service.yml kill
fi