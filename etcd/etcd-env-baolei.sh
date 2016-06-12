#!/bin/bash
# generate etcd environment variable

ETCD_GROUP="etcd_cluster_2"

cli addenv -k NODE_IP -v "10.3.148.146" -g k8s-148-146
cli addenv -k NODE_IP -v "10.3.148.147" -g k8s-148-147
cli addenv -k NODE_IP -v "10.3.148.148" -g k8s-148-148

cli addenv -k ETCD_NAME -v etcd0 -g k8s-148-146
cli addenv -k ETCD_NAME -v etcd1 -g k8s-148-147
cli addenv -k ETCD_NAME -v etcd2 -g k8s-148-148

cli addenv -k LISTEN_PEER_URLS -v http://10.3.148.146:2380,http://10.3.148.146:7001 -g k8s-148-146
cli addenv -k LISTEN_PEER_URLS -v http://10.3.148.147:2380,http://10.3.148.147:7001 -g k8s-148-147
cli addenv -k LISTEN_PEER_URLS -v http://10.3.148.148:2380,http://10.3.148.148:7001 -g k8s-148-148

cli addenv -k INITIAL_ADVERTISE_PEER_URLS -v http://10.3.148.146:2380,http://10.3.148.146:7001 -g k8s-148-146
cli addenv -k INITIAL_ADVERTISE_PEER_URLS -v http://10.3.148.147:2380,http://10.3.148.147:7001 -g k8s-148-147
cli addenv -k INITIAL_ADVERTISE_PEER_URLS -v http://10.3.148.148:2380,http://10.3.148.148:7001 -g k8s-148-148

cli addenv -k LISTEN_CLIENT_URLS -v http://10.3.148.146:2379,http://10.3.148.146:4001,http://127.0.0.1:2379 -g k8s-148-146
cli addenv -k LISTEN_CLIENT_URLS -v http://10.3.148.147:2379,http://10.3.148.147:4001,http://127.0.0.1:2379 -g k8s-148-147
cli addenv -k LISTEN_CLIENT_URLS -v http://10.3.148.148:2379,http://10.3.148.148:4001,http://127.0.0.1:2379 -g k8s-148-148

cli addenv -k ADVERTISE_CLIENT_URLS -v http://10.3.148.146:2379,http://10.3.148.146:4001 -g k8s-148-146
cli addenv -k ADVERTISE_CLIENT_URLS -v http://10.3.148.147:2379,http://10.3.148.147:4001 -g k8s-148-147
cli addenv -k ADVERTISE_CLIENT_URLS -v http://10.3.148.148:2379,http://10.3.148.148:4001 -g k8s-148-148

cli addenv -k INITIAL_CLUSTER_TOKEN -v etcd-cluster-2 -g ${ETCD_GROUP}
cli addenv -k INITIAL_CLUSTER -v etcd0=http://10.3.148.146:2380,etcd0=http://10.3.148.146:7001,etcd1=http://10.3.148.147:2380,etcd1=http://10.3.148.147:7001,etcd2=http://10.3.148.148:2380,etcd2=http://10.3.148.148:7001 -g ${ETCD_GROUP}
cli addenv -k INITIAL_CLUSTER_STATE -v new -g ${ETCD_GROUP}
