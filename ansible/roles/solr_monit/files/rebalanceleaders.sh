#!/bin/sh

BIOCACHE_COLLECTION="$( wget -q -O - "http://127.0.0.1:8983/solr/admin/collections?action=listaliases&wt=json&indent=true" | jq -r ".aliases|.biocache" )"

echo "Collection to rebalance: ${BIOCACHE_COLLECTION}"

wget -O "/tmp/rebalanceleaders-output.json" "http://localhost:8983/solr/admin/collections?action=REBALANCELEADERS&wt=json&indent=true&collection=${BIOCACHE_COLLECTION}"
