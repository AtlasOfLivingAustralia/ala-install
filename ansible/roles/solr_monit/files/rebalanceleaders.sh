#!/bin/sh

. ./biocache_collection.sh

echo "Collection to rebalance: ${BIOCACHE_COLLECTION}"

wget -O "/tmp/rebalanceleaders-output.json" "http://localhost:8983/solr/admin/collections?action=REBALANCELEADERS&wt=json&indent=true&collection=${BIOCACHE_COLLECTION}"
