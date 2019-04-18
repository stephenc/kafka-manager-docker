FROM openjdk:8-jdk-alpine

ARG KAFKA_MANAGER=2.0.0.2::SHA::363f6619dd0ec82a53b4e304df62895e219fba2f83438c50953c32f695ca4e3b

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

ARG ENVSUB=0.1.0::SHA::b10600c03236bbf0711476e11a1dff9ae285a50a48568bfd0bf6c6014fc69f0c
ARG ZKINIT=0.1.0::SHA::0556c0f53e94bb27718023f98807c6ea8232eddc6324597ec7c7c0385dd7484c

COPY --from=0 /tmp/kafka-manager/target/universal/kafka-manager-*.zip /opt/kafka-manager.zip

RUN apk add --no-cache bash tini curl \
    && cd /opt \
    && unzip kafka-manager.zip \
    && for n in kafka-manager-* ; do \
        mv $n kafka-manager; \
        break ; \
    done \
    && ln -s /opt/kafka-manager/bin/kafka-manager /usr/bin/kafka-manager \
\
    #
    # Get envsub
    #
\
    && curl -fsSL "https://github.com/stephenc/envsub/releases/download/${ENVSUB%%::SHA::*}/envsub" -o /usr/local/bin/envsub \
    && if [ "${ENVSUB##*::SHA::}" = "${ENVSUB}" ] ; then \
        echo "/usr/local/bin/envsub: Unverified" >&2 ; \
    else \
        echo "${ENVSUB##*::SHA::}  /usr/local/bin/envsub" | sha256sum -c - ; \
    fi \
    && chmod +x /usr/local/bin/envsub \
\
    #
    # Get zkinit
    #
\
    && curl -fsSL "https://github.com/stephenc/zkinit/releases/download/${ZKINIT%%::SHA::*}/zkinit" -o /usr/local/bin/zkinit \
    && if [ "${ZKINIT##*::SHA::}" = "${ZKINIT}" ] ; then \
        echo "/usr/local/bin/zkinit: Unverified" >&2 ; \
    else \
        echo "${ZKINIT##*::SHA::}  /usr/local/bin/zkinit" | sha256sum -c - ; \
    fi \
    && chmod +x /usr/local/bin/zkinit 

WORKDIR /opt/kafka-manager

ENTRYPOINT ["/sbin/tini", "-g", "--"]

COPY rootfs/ /

CMD ["/docker-entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=1500ms --start-period=10s --retries=3 CMD ["/docker-healthcheck.sh"]

EXPOSE 8080

ENV KM_CONFIGFILE="conf/application.conf"
