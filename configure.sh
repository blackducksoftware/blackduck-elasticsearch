#!/bin/bash

echo "Waiting for Elasticsearch to start..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://127.0.0.1:9200/_cat/health)" != "200" ]]; do sleep 1; done

echo "Importing..."
for file in /usr/share/elasticsearch/index_templates/*.json; do
    [ -e "$file" ] || continue
    fileName=$(basename $file)   
    indexName=${fileName%.*}
    curl --silent -X PUT "localhost:9200/_template/${indexName##*/}" -H 'Content-Type: application/json' -d@${file}
done

echo "All templates imported"
