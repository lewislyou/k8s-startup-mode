#!/bin/bash
# generate etcd environment variable

ETCD_GROUP="etcd_cluster_1"

cli addenv -k NODE_IP -v "172.17.32.46" -g mz-redis-32-46
cli addenv -k NODE_IP -v "172.17.32.47" -g mz-redis-32-47
cli addenv -k NODE_IP -v "172.17.32.48" -g mz-redis-32-48

cli addenv -k ETCD_NAME -v etcd0 -g mz-redis-32-46
cli addenv -k ETCD_NAME -v etcd1 -g mz-redis-32-47
cli addenv -k ETCD_NAME -v etcd2 -g mz-redis-32-48

cli addenv -k LISTEN_PEER_URLS -v http://172.17.32.46:2380,http://172.17.32.46:7001 -g mz-redis-32-46
cli addenv -k LISTEN_PEER_URLS -v http://172.17.32.47:2380,http://172.17.32.47:7001 -g mz-redis-32-47
cli addenv -k LISTEN_PEER_URLS -v http://172.17.32.48:2380,http://172.17.32.48:7001 -g mz-redis-32-48

cli addenv -k INITIAL_ADVERTISE_PEER_URLS -v http://172.17.32.46:2380,http://172.17.32.46:7001 -g mz-redis-32-46
cli addenv -k INITIAL_ADVERTISE_PEER_URLS -v http://172.17.32.47:2380,http://172.17.32.47:7001 -g mz-redis-32-47
cli addenv -k INITIAL_ADVERTISE_PEER_URLS -v http://172.17.32.48:2380,http://172.17.32.48:7001 -g mz-redis-32-48

cli addenv -k LISTEN_CLIENT_URLS -v http://172.17.32.46:2379,http://172.17.32.46:4001,http://127.0.0.1:2379 -g mz-redis-32-46
cli addenv -k LISTEN_CLIENT_URLS -v http://172.17.32.47:2379,http://172.17.32.47:4001,http://127.0.0.1:2379 -g mz-redis-32-47
cli addenv -k LISTEN_CLIENT_URLS -v http://172.17.32.48:2379,http://172.17.32.48:4001,http://127.0.0.1:2379 -g mz-redis-32-48

cli addenv -k ADVERTISE_CLIENT_URLS -v http://172.17.32.46:2379,http://172.17.32.46:4001 -g mz-redis-32-46
cli addenv -k ADVERTISE_CLIENT_URLS -v http://172.17.32.47:2379,http://172.17.32.47:4001 -g mz-redis-32-47
cli addenv -k ADVERTISE_CLIENT_URLS -v http://172.17.32.48:2379,http://172.17.32.48:4001 -g mz-redis-32-48

cli addenv -k INITIAL_CLUSTER_TOKEN -v etcd-cluster-1 -g ${ETCD_GROUP}
cli addenv -k INITIAL_CLUSTER -v etcd0=http://172.17.32.46:2380,etcd0=http://172.17.32.46:7001,etcd1=http://172.17.32.47:2380,etcd1=http://172.17.32.47:7001,etcd2=http://172.17.32.48:2380,etcd2=http://172.17.32.48:7001 -g ${ETCD_GROUP}
cli addenv -k INITIAL_CLUSTER_STATE -v new -g ${ETCD_GROUP}
