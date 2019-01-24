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
