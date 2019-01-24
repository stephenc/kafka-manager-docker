FROM openjdk:8-jdk-alpine

ARG KAFKA_MANAGER=1.3.3.22::SHA::96cd4e4fe285c9c88c4b67a7d22010942a2794456672037f440957fd7bdd89a4

RUN apk add --no-cache bash curl

RUN curl -fsSL "https://github.com/yahoo/kafka-manager/archive/${KAFKA_MANAGER%%::SHA::*}.tar.gz" -o /tmp/kafka-manager.tar.gz \
    && if [ "${KAFKA_MANAGER##*::SHA::}" = "${KAFKA_MANAGER}" ] ; then \
        echo "/tmp/kafka-manager.tar.gz: Unverified" >&2 ; \
    else \
        echo "${KAFKA_MANAGER##*::SHA::}  /tmp/kafka-manager.tar.gz" | sha256sum -c - ; \
    fi \
    && mkdir -p /tmp/kafka-manager && tar -xzf /tmp/kafka-manager.tar.gz -C /tmp/kafka-manager --strip-components 1

RUN cd /tmp/kafka-manager \
    && ./sbt clean dist

RUN mkdir -p /opt \
    && cd /opt \
    && unzip /tmp/kafka-manager/target/universal/kafka-manager-${KAFKA_MANAGER%%::SHA::*}.zip \
    && mv kafka-manager-${KAFKA_MANAGER%%::SHA::*} kafka-manager

FROM openjdk:8-jre-alpine

COPY --from=0 /tmp/kafka-manager/target/universal/kafka-manager-*.zip /opt/kafka-manager.zip

RUN apk add --no-cache bash tini \
    && cd /opt \
    && unzip kafka-manager.zip \
    && for n in kafka-manager-* ; do \
        mv $n kafka-manager; \
        break ; \
    done \
    && ln -s /opt/kafka-manager/bin/kafka-manager /usr/bin/kafka-manager 

WORKDIR /opt/kafka-manager

ENTRYPOINT ["/sbin/tini", "-g", "--"]

COPY rootfs/ /

CMD ["/docker-entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=1500ms --start-period=10s --retries=3 CMD ["/docker-healthcheck.sh"]

EXPOSE 9000


ENV KM_CONFIGFILE="conf/application.conf"
