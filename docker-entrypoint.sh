#!/bin/bash
set -e

${HUB_APPLICATION_HOME}/bin/configure.sh &

#SET FILEBEAT#
echo "Attempting to start "$($BLACKDUCK_HOME/filebeat/filebeat --version)
$BLACKDUCK_HOME/filebeat/filebeat -c $BLACKDUCK_HOME/filebeat/filebeat.yml start &

/usr/local/bin/docker-entrypoint.sh $@
