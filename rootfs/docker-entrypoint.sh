#!/usr/bin/env bash
set -eo pipefail

if [[ $KM_USERNAME != ''  && $KM_PASSWORD != '' ]]; then
    sed -i.bak '/^basicAuthentication/d' /opt/kafka-manager/conf/application.conf
    echo 'basicAuthentication.enabled=true' >> /opt/kafka-manager/conf/application.conf
    echo "basicAuthentication.username=${KM_USERNAME}" >> /opt/kafka-manager/conf/application.conf
    echo "basicAuthentication.password=${KM_PASSWORD}" >> /opt/kafka-manager/conf/application.conf
    echo 'basicAuthentication.realm="Kafka-Manager"' >> /opt/kafka-manager/conf/application.conf
fi

exec kafka-manager -Dconfig.file=${KM_CONFIGFILE} "${KM_ARGS}" "${@}"