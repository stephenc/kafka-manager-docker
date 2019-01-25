#!/usr/bin/env bash
set -eo pipefail

if [ -n "${KM_ADD_CLUSTER}" ] ; then
    CLUSTER_NAME=${KM_ADD_CLUSTER%%=*} CLUSTER_ZOOKEEPER=${KM_ADD_CLUSTER##*=} envsub \
        -v CLUSTER_NAME \
        -v CLUSTER_ZOOKEEPER \
        < /opt/cluster-template.json \
        > /tmp/cluster-template.json
    zkinit -p "/kafka-manager/configs/${KM_ADD_CLUSTER%%=*}" "/tmp/cluster-template.json"
fi

kafka-manager -Dhttp.port=8080 -Dapplication.home=/opt/kafka-manager "${KM_ARGS}" "${@}"
