#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Create etcd.conf, etcd.service, and start etcd service.
ETCD_GROUP="etcd_cluster_2"
NODE_NAME=$(hostname)
cli listenv -g ${ETCD_GROUP} > etcd-default
cli listenv -g ${NODE_NAME} > node-default
source etcd-default
source node-default
#NODE_IP=$(cli getenv -k NODE_IP -g ${NODE_NAME})
#ETCD_NAME=$(cli getenv -k ETCD_NAME -g ${NODE_NAME})
#INITIAL_ADVERTISE_PEER_URLS=$(cli getenv -k INITIAL_ADVERTISE_PEER_URLS -g ${NODE_NAME})
#LISTEN_PEER_URLS=$(cli getenv -k LISTEN_PEER_URLS -g ${NODE_NAME})
#LISTEN_CLIENT_URLS=$(cli getenv -k LISTEN_CLIENT_URLS -g ${NODE_NAME})
#ADVERTISE_CLIENT_URLS=$(cli getenv -k ADVERTISE_CLIENT_URLS -g ${NODE_NAME})
#INITIAL_CLUSTER_TOKEN=$(cli getenv -k INITIAL_CLUSTER_TOKEN -g ${ETCD_GROUP})
#INITIAL_CLUSTER=$(cli getenv -k INITIAL_CLUSTER -g ${ETCD_GROUP})
#INITIAL_CLUSTER_STATE=$(cli getenv -k INITIAL_CLUSTER_STATE -g ${ETCD_GROUP})

#etcd_data_dir=/var/lib/etcd/
#mkdir -p ${etcd_data_dir}

cat <<EOF >/opt/kubernetes/cfg/etcd.conf
# [member]
ETCD_NAME=${ETCD_NAME}
#ETCD_DATA_DIR="${etcd_data_dir}/default.etcd"
#ETCD_SNAPSHOT_COUNTER="10000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
#ETCD_LISTEN_PEER_URLS="http://${MASTER_IP}:2380,http://${MASTER_IP}:7001"
ETCD_LISTEN_PEER_URLS=${LISTEN_PEER_URLS}
#ETCD_LISTEN_CLIENT_URLS="http://${MASTER_IP}:2379,http://${MASTER_IP}:4001,http://127.0.0.1:2379"
ETCD_LISTEN_CLIENT_URLS=${LISTEN_CLIENT_URLS}
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#
#[cluster]
#ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${MASTER_IP}:2380,http://${MASTER_IP}:7001"
ETCD_INITIAL_ADVERTISE_PEER_URLS=${INITIAL_ADVERTISE_PEER_URLS}
# if you use different ETCD_NAME (e.g. test), 
# set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
#ETCD_INITIAL_CLUSTER="etcd0=http://172.17.32.46:2380,etcd0=http://172.17.32.46:7001,etcd1=http://172.17.32.47:2380,etcd1=http://172.17.32.47:7001,etcd2=http://172.17.32.48:2380,etcd2=http://172.17.32.48:7001"
ETCD_INITIAL_CLUSTER=${INITIAL_CLUSTER}
#ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_STATE=${INITIAL_CLUSTER_STATE}
#ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_TOKEN=${INITIAL_CLUSTER_TOKEN}
#ETCD_ADVERTISE_CLIENT_URLS="http://${MASTER_IP}:2379,http://${MASTER_IP}:4001"
ETCD_ADVERTISE_CLIENT_URLS=${ADVERTISE_CLIENT_URLS}
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#
#[proxy]
#ETCD_PROXY="off"
#
#[security]
#ETCD_CA_FILE=""
#ETCD_CERT_FILE=""
#ETCD_KEY_FILE=""
#ETCD_PEER_CA_FILE=""
#ETCD_PEER_CERT_FILE=""
#ETCD_PEER_KEY_FILE=""
EOF

cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=simple
WorkingDirectory=${etcd_data_dir}
EnvironmentFile=-/opt/kubernetes/cfg/etcd.conf
# set GOMAXPROCS to number of processors
ExecStart=/bin/bash -c "GOMAXPROCS=\$(nproc) /opt/kubernetes/bin/etcd"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
