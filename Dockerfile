FROM docker.elastic.co/elasticsearch/elasticsearch:6.5.4

ARG VERSION
ARG LASTCOMMIT
ARG BUILDTIME
ARG BUILD

LABEL com.blackducksoftware.hub.vendor="Black Duck Software, Inc." \
      com.blackducksoftware.hub.version="$VERSION" \
      com.blackducksoftware.hub.lastCommit="$LASTCOMMIT" \
      com.blackducksoftware.hub.buildTime="$BUILDTIME" \
      com.blackducksoftware.hub.build="$BUILD" \
      com.blackducksoftware.hub.image="postgres"

ENV BLACKDUCK_RELEASE_INFO "com.blackducksoftware.hub.vendor=Black Duck Software, Inc. \
com.blackducksoftware.hub.version=$VERSION \
com.blackducksoftware.hub.lastCommit=$LASTCOMMIT \
com.blackducksoftware.hub.buildTime=$BUILDTIME \
com.blackducksoftware.hub.build=$BUILD"

RUN echo -e "$BLACKDUCK_RELEASE_INFO" > /etc/blackduckrelease

ENV HUB_APPLICATION_NAME="hub-elasticsearch"
ENV BLACKDUCK_HOME="/opt/blackduck/hub"
ENV HUB_APPLICATION_HOME="${BLACKDUCK_HOME}/${HUB_APPLICATION_NAME}"

RUN mkdir -p ${HUB_APPLICATION_HOME}/bin $HUB_APPLICATION_HOME/conf $HUB_APPLICATION_HOME/lib $HUB_APPLICATION_HOME/logs    

COPY configure.sh docker-entrypoint.sh ${HUB_APPLICATION_HOME}/bin/
COPY index_templates /usr/share/elasticsearch/index_templates
COPY log4j2.properties /usr/share/elasticsearch/config/

# Pre populate index templates in Elasticsearch
RUN /usr/local/bin/docker-entrypoint.sh elasticsearch -p /tmp/epid & \
    ${HUB_APPLICATION_HOME}/bin/configure.sh && \
    kill $(cat /tmp/epid) && wait $(cat /tmp/epid); exit 0;

ENV FILEBEAT_VERSION 5.5.2
RUN set -e \
	&& curl -L https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-$FILEBEAT_VERSION-linux-x86_64.tar.gz | \
    tar xz -C $BLACKDUCK_HOME \
    && mv $BLACKDUCK_HOME/filebeat-$FILEBEAT_VERSION-linux-x86_64 $BLACKDUCK_HOME/filebeat        

COPY filebeat.yml "$BLACKDUCK_HOME/filebeat/"

RUN	chmod -R og+rwx "$BLACKDUCK_HOME/filebeat" \
	&& chmod 644 "$BLACKDUCK_HOME/filebeat/filebeat.yml" \
    && chown -R elasticsearch ${HUB_APPLICATION_HOME}

ENTRYPOINT ["/opt/blackduck/hub/hub-elasticsearch/bin/docker-entrypoint.sh"]
