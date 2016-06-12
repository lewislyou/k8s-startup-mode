#!/bin/bash

# common setting

# warn: GROUP is the name of configuration group, which is unique for every kubernetes cluster, select one name different from others, or you'll overlay other's configuration group
GROUP=$1
DEFAULT_CONFIG_FILE=/opt/kubernetes/cfg/config
LOCAL_ADDRESS=`ip addr |grep -oE 'inet \w+.\w+.\w+.\w+' |awk '{print $2}'|grep '172.16'`

########################################## common options ################################################
MASTER_IP=${LOCAL_ADDRESS}
OVERLAY_TYPE="calico"
SERVICE_CLUSTER_IP_RANGE="192.168.3.0/24"
POD_INFRA_IMAGE="reg.local:5000/pause:2.0"

# define the IP range used for flannel overlay network, should not conflict with above SERVICE_CLUSTER_IP_RANGE
FLANNEL_NET="172.28.0.0/16"

# Admission Controllers to invoke prior to persisting objects in cluster
ADMISSION_CONTROL="NamespaceLifecycle,NamespaceExists,LimitRanger,ServiceAccount,ResourceQuota,SecurityContextDeny"
DNS_SERVER_IP="192.168.3.10" 
DNS_DOMAIN="cluster.local"

# etcd
ETCD_HOST=172.16.16.113
ETCD_PORT=4001
ETCD_SERVERS=http://${ETCD_HOST}:${ETCD_PORT}



########################################## apiserver options ##############################################
#
# --logtostderr=true: log to standard error instead of files
API_KUBE_LOGTOSTDERR="--logtostderr=true"

# --v=0: log level for V logs
API_KUBE_LOG_LEVEL="--v=4"

# --etcd-servers=[]: List of etcd servers to watch (http://ip:port),
# comma separated. Mutually exclusive with -etcd-config
API_KUBE_ETCD_SERVERS="--etcd-servers=${ETCD_SERVERS}"

# --insecure-bind-address=127.0.0.1: The IP address on which to serve the --insecure-port.
API_KUBE_API_ADDRESS="--insecure-bind-address=${MASTER_IP}"

# --insecure-port=8080: The port on which to serve unsecured, unauthenticated access.
API_KUBE_API_PORT="--insecure-port=8080"

# --kubelet-port=10250: Kubelet port
API_NODE_PORT="--kubelet-port=10250"

# --advertise-address=<nil>: The IP address on which to advertise
# the apiserver to members of the cluster.
API_KUBE_ADVERTISE_ADDR="--advertise-address=${MASTER_IP}"

# --allow-privileged=false: If true, allow privileged containers.
API_KUBE_ALLOW_PRIV="--allow-privileged=true"

# --service-cluster-ip-range=<nil>: A CIDR notation IP range from which to assign service cluster IPs.
# This must not overlap with any IP ranges assigned to nodes for pods.
API_KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"

# --admission-control="AlwaysAdmit": Ordered list of plug-ins
# to do admission control of resources into cluster.
# Comma-delimited list of:
#   LimitRanger, AlwaysDeny, SecurityContextDeny, NamespaceExists,
#   NamespaceLifecycle, NamespaceAutoProvision,
#   AlwaysAdmit, ServiceAccount, ResourceQuota
API_KUBE_ADMISSION_CONTROL="--admission-control=${ADMISSION_CONTROL}"

# --client-ca-file="": If set, any request presenting a client certificate signed
# by one of the authorities in the client-ca-file is authenticated with an identity
# corresponding to the CommonName of the client certificate.
API_KUBE_API_CLIENT_CA_FILE="--client-ca-file=/srv/kubernetes/ca.crt"

# --tls-cert-file="": File containing x509 Certificate for HTTPS.  (CA cert, if any,
# concatenated after server cert). If HTTPS serving is enabled, and --tls-cert-file
# and --tls-private-key-file are not provided, a self-signed certificate and key are
# generated for the public address and saved to /var/run/kubernetes.
API_KUBE_API_TLS_CERT_FILE="--tls-cert-file=/srv/kubernetes/server.cert"

# --tls-private-key-file="": File containing x509 private key matching --tls-cert-file.
API_KUBE_API_TLS_PRIVATE_KEY_FILE="--tls-private-key-file=/srv/kubernetes/server.key"



########################################## scheduler options ##############################################

# --logtostderr=true: log to standard error instead of files
SCHEDULER_KUBE_LOGTOSTDERR="--logtostderr=true"

# --V=0: log level for v logs
SCHEDULER_KUBE_LOG_LEVEL="--v=4"

SCHEDULER_KUBE_SCHEDULER_LEADER_ELECT="--leader_elect=true"

SCHEDULER_KUBE_MASTER="--master=${MASTER_IP}:8080"

# Add your own!
SCHEDULER_KUBE_SCHEDULER_ARGS=""



########################################## controller-manager options ##############################################

CONTROLLER_KUBE_LOGTOSTDERR="--logtostderr=true"
CONTROLLER_KUBE_LOG_LEVEL="--v=4"
CONTROLLER_KUBE_MASTER="--master=${MASTER_IP}:8080"

# --root-ca-file="": If set, this root certificate authority will be included in
# service account's token secret. This must be a valid PEM-encoded CA bundle.
CONTROLLER_KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE="--root-ca-file=/srv/kubernetes/ca.crt"

CONTROLLER_KUBE_CONTROLLER_MANAGER_LEADER_ELECT="--leader-elect=true"
# --service-account-private-key-file="": Filename containing  a PEM-encoded private
# RSA key used to sign service account tokens.
CONTROLLER_KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE="--service-account-private-key-fiLe=/srv/kubernetes/server.key"



########################################## proxy options ##############################################
# --logtostderr=true: log to standard error instead of files
PROXY_KUBE_LOGTOSTDERR="--logtostderr=true"

# --v=0: log level for v logs
PROXY_KUBE_LOG_LEVEL="--v=4"

PROXY_MODE="--proxy-mode=iptables"

# --master="": The address of the Kubernetes API server (overrides any value in kubeconfig)
PROXY_KUBE_MASTER="--master=http://${MASTER_IP}:8080"


########################################## docker options ##############################################
DOCKER_COMMON_OPTS="--insecure-registry=reg.local:5000 --registry-mirror=http://eccb1380.m.daocloud.io"
DOCKER_OPTS=" -H tcp://127.0.0.1:4243 -H unix:///var/run/docker.sock -s devicemapper --selinux-enabled=false ${DOCKER_COMMON_OPTS} --bridge=none"



########################################## flannel options ##############################################
FLANNEL_ETCD="-etcd-endpoints=${ETCD_SERVERS}"
FLANNEL_ETCD_KEY="-etcd-prefix=/coreos.com/network"


########################################## kubelet options ##############################################
#  --logtostderr=true: log to standard error instead of files
KUBELET_KUBE_LOGTOSTDERR="--logtostderr=true"

# --v=0: loglevel for v logs
KUBELET_KUBE_LOG_LEVEL="--v=4"

# --port=10250: The port for the Kubelet to serve on. Note that "kubectl logs" will not work if you set this flag.
KUBELET_NODE_PORT="--port=10250"

# --api-servers=[]: List of Kubernetes API servers for publishing events,
# and reading pods and services. (ip:port), comma separated.
KUBELET_API_SERVER="--api-servers=${MASTER_IP}:8080"

# --allow-privileged=false: If true, allow containers to request privileged mode. [default=false]
KUBELET_KUBE_ALLOW_PRIV="--allow-privileged=true"


if [ ${OVERLAY_TYPE} == "calico" ]; then
    KUBELET_NET_DIR="--network-plugin-dir=/etc/cni/net.d"
    KUBELET_PLUGIN="--network-plugin=cni"
else
    KUBELET_NET_DIR=""
    KUBELET_PLUGIN=""
fi

KUBELET_ARGS=""

KUBELET_KUBE_DNS_SERVER="--cluster-dns=${DNS_SERVER_IP}"

KUBELET_KUBE_CONFIG="--config=/etc/kubernetes/manifests"

KUBELET_KUBE_DNS_DOMAIN="--cluster-domain=${DNS_DOMAIN}"

KUBELET_KUBE_INFRA_IMG="--pod-infra-container-image=${POD_INFRA_IMAGE}"


########################################## calico options ##############################################
CALICO_NODE_IMAGE="--node-image=reg.local:5000/calico-node:latest"
CALICO_DETACH="--detach=false"
ETCD_AUTHORITY="${MASTER_IP}:4001"





################################################  ETCD  NODE  ############################################################################
# etcd server setting 
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="${ETCD_SERVERS}"
ETCD_ADVERTISE_CLIENT_URLS="${ETCD_SERVERS}"
export ETCD_OPTS=" --data-dir=${ETCD_DATA_DIR} --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS}"


################################################  SHELL FUNCTION #############################################################################




function del_env() {
   cli delenv -k MASTER_IP -g ${GROUP}
   cli delenv -k ETCD_SERVERS -g ${GROUP}
   cli delenv -k OVERLAY_TYPE -g ${GROUP}
   cli delenv -k FLANNEL_NET -g ${GROUP}
   cli delenv -k DNS_SERVER_IP -g ${GROUP}
   cli delenv -k DNS_DOMAIN -g ${GROUP}
   cli delenv -k POD_INFRA_IMAGE -g ${GROUP}

   cli delenv -k SERVICE_CLUSTER_IP_RANGE -g ${GROUP}
# apiserver options
   cli delenv -k API_KUBE_LOGTOSTDERR -g ${GROUP}
   cli delenv -k API_KUBE_LOG_LEVEL -g ${GROUP}
   cli delenv -k API_KUBE_ETCD_SERVERS -g ${GROUP}
   cli delenv -k API_KUBE_API_ADDRESS -g ${GROUP}
   cli delenv -k API_KUBE_API_PORT -g ${GROUP}

   cli delenv -k API_NODE_PORT -g ${GROUP}
   cli delenv -k API_KUBE_ADVERTISE_ADDR -g ${GROUP}
   cli delenv -k API_KUBE_ALLOW_PRIV -g ${GROUP}
   cli delenv -k API_KUBE_SERVICE_ADDRESSES -g ${GROUP}
   cli delenv -k API_KUBE_ADMISSION_CONTROL -g ${GROUP}

   cli delenv -k API_KUBE_API_CLIENT_CA_FILE -g ${GROUP}
   cli delenv -k API_KUBE_API_TLS_CERT_FILE -g ${GROUP}
   cli delenv -k API_KUBE_API_TLS_PRIVATE_KEY_FILE -g ${GROUP}

# scheduler options
   cli delenv -k SCHEDULER_KUBE_LOGTOSTDERR -g ${GROUP}
   cli delenv -k SCHEDULER_KUBE_LOG_LEVEL -g ${GROUP}
   cli delenv -k SCHEDULER_KUBE_MASTER -g ${GROUP}
   cli delenv -k SCHEDULER_KUBE_SCHEDULER_LEADER_ELECT -g ${GROUP}
   cli delenv -k SCHEDULER_KUBE_SCHEDULER_ARGS -g ${GROUP}

# controller-manager options
   cli delenv -k CONTROLLER_KUBE_LOGTOSTDERR -g ${GROUP}
   cli delenv -k CONTROLLER_KUBE_LOG_LEVEL -g ${GROUP}
   cli delenv -k CONTROLLER_KUBE_MASTER -g ${GROUP}
   cli delenv -k CONTROLLER_KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE -g ${GROUP}
   cli delenv -k CONTROLLER_KUBE_CONTROLLER_MANAGER_LEADER_ELECT -g ${GROUP}
   cli delenv -k CONTROLLER_KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE -g ${GROUP}

# flannel options
   cli delenv -k FLANNEL_ETCD -g ${GROUP}
   cli delenv -k FLANNEL_ETCD_KEY -g ${GROUP}

# calico options
   cli delenv -k CALICO_NODE_IMAGE -g ${GROUP}
   cli delenv -k CALICO_DETACH -g ${GROUP}
   cli delenv -k ETCD_AUTHORITY -g ${GROUP}

# docker options
   cli delenv -k DOCKER_OPTS -g ${GROUP}

# proxy options
   cli delenv -k PROXY_KUBE_LOGTOSTDERR -g ${GROUP}
   cli delenv -k PROXY_KUBE_LOG_LEVEL -g ${GROUP}
   cli delenv -k PROXY_MODE -g ${GROUP}
   cli delenv -k PROXY_KUBE_MASTER -g ${GROUP}

# kubelet options
   cli delenv -k KUBELET_KUBE_LOGTOSTDERR -g ${GROUP}
   cli delenv -k KUBELET_KUBE_LOG_LEVEL -g ${GROUP}
   cli delenv -k KUBELET_NODE_PORT -g ${GROUP}
   cli delenv -k KUBELET_API_SERVER -g ${GROUP}
   cli delenv -k KUBELET_KUBE_ALLOW_PRIV -g ${GROUP}
   cli delenv -k KUBELET_ARGS -g ${GROUP}
   cli delenv -k KUBELET_KUBE_DNS_SERVER -g ${GROUP}
   cli delenv -k KUBELET_KUBE_DNS_DOMAIN -g ${GROUP}
   cli delenv -k KUBELET_KUBE_CONFIG -g ${GROUP}
   cli delenv -k KUBELET_KUBE_INFRA_IMG -g ${GROUP}
   cli delenv -k KUBELET_NET_DIR -g ${GROUP}
   cli delenv -k KUBELET_PLUGIN -g ${GROUP}

}

function add_env() {
   cli addenv -k MASTER_IP -v "\"${MASTER_IP}\"" -g ${GROUP}
   cli addenv -k ETCD_SERVERS -v "\"${ETCD_SERVERS}\"" -g ${GROUP}
   cli addenv -k OVERLAY_TYPE -v "\"${OVERLAY_TYPE}\"" -g ${GROUP}
   cli addenv -k FLANNEL_NET -v "\"${FLANNEL_NET}\"" -g ${GROUP}
   cli addenv -k DNS_SERVER_IP -v "\"${DNS_SERVER_IP}\"" -g ${GROUP}
   cli addenv -k DNS_DOMAIN -v "\"${DNS_DOMAIN}\"" -g ${GROUP}
   cli addenv -k POD_INFRA_IMAGE -v "\"${POD_INFRA_IMAGE}\"" -g ${GROUP}

   cli addenv -k SERVICE_CLUSTER_IP_RANGE -v "\"${SERVICE_CLUSTER_IP_RANGE}\"" -g ${GROUP}

# apiserver options
   cli addenv -k API_KUBE_LOGTOSTDERR -v "\"${API_KUBE_LOGTOSTDERR}\"" -g ${GROUP}
   cli addenv -k API_KUBE_LOG_LEVEL -v "\"${API_KUBE_LOG_LEVEL}\"" -g ${GROUP}
   cli addenv -k API_KUBE_ETCD_SERVERS -v "\"${API_KUBE_ETCD_SERVERS}\"" -g ${GROUP}
   cli addenv -k API_KUBE_API_ADDRESS -v "\"${API_KUBE_API_ADDRESS}\"" -g ${GROUP}
   cli addenv -k API_KUBE_API_PORT -v "\"${API_KUBE_API_PORT}\"" -g ${GROUP}

   cli addenv -k API_NODE_PORT -v "\"${API_NODE_PORT}\"" -g ${GROUP}
   cli addenv -k API_KUBE_ADVERTISE_ADDR -v "\"${API_KUBE_ADVERTISE_ADDR}\"" -g ${GROUP}
   cli addenv -k API_KUBE_ALLOW_PRIV -v "\"${API_KUBE_ALLOW_PRIV}\"" -g ${GROUP}
   cli addenv -k API_KUBE_SERVICE_ADDRESSES -v "\"${API_KUBE_SERVICE_ADDRESSES}\"" -g ${GROUP}
   cli addenv -k API_KUBE_ADMISSION_CONTROL -v "\"${API_KUBE_ADMISSION_CONTROL}\"" -g ${GROUP}

   cli addenv -k API_KUBE_API_CLIENT_CA_FILE -v "\"${API_KUBE_API_CLIENT_CA_FILE}\"" -g ${GROUP}
   cli addenv -k API_KUBE_API_TLS_CERT_FILE -v "\"${API_KUBE_API_TLS_CERT_FILE}\"" -g ${GROUP}
   cli addenv -k API_KUBE_API_TLS_PRIVATE_KEY_FILE -v "\"${API_KUBE_API_TLS_PRIVATE_KEY_FILE}\"" -g ${GROUP}

# scheduler options
   cli addenv -k SCHEDULER_KUBE_LOGTOSTDERR -v "\"${SCHEDULER_KUBE_LOGTOSTDERR}\"" -g ${GROUP}
   cli addenv -k SCHEDULER_KUBE_LOG_LEVEL -v "\"${SCHEDULER_KUBE_LOG_LEVEL}\"" -g ${GROUP}
   cli addenv -k SCHEDULER_KUBE_MASTER -v "\"${SCHEDULER_KUBE_MASTER}\"" -g ${GROUP}
   cli addenv -k SCHEDULER_KUBE_SCHEDULER_LEADER_ELECT -v "\"${SCHEDULER_KUBE_SCHEDULER_LEADER_ELECT}\"" -g ${GROUP}
   cli addenv -k SCHEDULER_KUBE_SCHEDULER_ARGS -v "\"${SCHEDULER_KUBE_SCHEDULER_ARGS}\"" -g ${GROUP}

# controller-manager options
   cli addenv -k CONTROLLER_KUBE_LOGTOSTDERR -v "\"${CONTROLLER_KUBE_LOGTOSTDERR}\"" -g ${GROUP}
   cli addenv -k CONTROLLER_KUBE_LOG_LEVEL -v "\"${CONTROLLER_KUBE_LOG_LEVEL}\"" -g ${GROUP}
   cli addenv -k CONTROLLER_KUBE_MASTER -v "\"${CONTROLLER_KUBE_MASTER}\"" -g ${GROUP}
   cli addenv -k CONTROLLER_KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE -v "\"${CONTROLLER_KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE}\"" -g ${GROUP}
   cli addenv -k CONTROLLER_KUBE_CONTROLLER_MANAGER_LEADER_ELECT -v "\"${CONTROLLER_KUBE_CONTROLLER_MANAGER_LEADER_ELECT}\"" -g ${GROUP}
   cli addenv -k CONTROLLER_KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE -v "\"${CONTROLLER_KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE}\"" -g ${GROUP}

# flannel options
   cli addenv -k FLANNEL_ETCD -v "\"${FLANNEL_ETCD}\"" -g ${GROUP}
   cli addenv -k FLANNEL_ETCD_KEY -v "\"${FLANNEL_ETCD_KEY}\"" -g ${GROUP}

# calico options
   cli addenv -k CALICO_NODE_IMAGE -v "\"${CALICO_NODE_IMAGE}\"" -g ${GROUP}
   cli addenv -k CALICO_DETACH -v "\"${CALICO_DETACH}\"" -g ${GROUP}
   cli addenv -k ETCD_AUTHORITY -v "\"${ETCD_AUTHORITY}\"" -g ${GROUP}

# docker options
   cli addenv -k DOCKER_OPTS -v "\"${DOCKER_OPTS}\"" -g ${GROUP}

# proxy options
   cli addenv -k PROXY_KUBE_LOGTOSTDERR -v "\"${PROXY_KUBE_LOGTOSTDERR}\"" -g ${GROUP}
   cli addenv -k PROXY_KUBE_LOG_LEVEL -v "\"${PROXY_KUBE_LOG_LEVEL}\"" -g ${GROUP}
   cli addenv -k PROXY_MODE -v "\"${PROXY_MODE}\"" -g ${GROUP}
   cli addenv -k PROXY_KUBE_MASTER -v "\"${PROXY_KUBE_MASTER}\"" -g ${GROUP}
   
# kubelet options
   cli addenv -k KUBELET_KUBE_LOGTOSTDERR -v "\"${KUBELET_KUBE_LOGTOSTDERR}\"" -g ${GROUP}
   cli addenv -k KUBELET_KUBE_LOG_LEVEL -v "\"${KUBELET_KUBE_LOG_LEVEL}\"" -g ${GROUP}
   cli addenv -k KUBELET_NODE_PORT -v "\"${KUBELET_NODE_PORT}\"" -g ${GROUP}
   cli addenv -k KUBELET_API_SERVER -v "\"${KUBELET_API_SERVER}\"" -g ${GROUP}
   cli addenv -k KUBELET_KUBE_ALLOW_PRIV -v "\"${KUBELET_KUBE_ALLOW_PRIV}\"" -g ${GROUP}
   cli addenv -k KUBELET_ARGS -v "\"${KUBELET_ARGS}\"" -g ${GROUP}
   cli addenv -k KUBELET_KUBE_DNS_SERVER -v "\"${KUBELET_KUBE_DNS_SERVER}\"" -g ${GROUP}
   cli addenv -k KUBELET_KUBE_DNS_DOMAIN -v "\"${KUBELET_KUBE_DNS_DOMAIN}\"" -g ${GROUP}
   cli addenv -k KUBELET_KUBE_CONFIG -v "\"${KUBELET_KUBE_CONFIG}\"" -g ${GROUP}
   cli addenv -k KUBELET_KUBE_INFRA_IMG -v "\"${KUBELET_KUBE_INFRA_IMG}\"" -g ${GROUP}
   cli addenv -k KUBELET_NET_DIR -v "\"${KUBELET_NET_DIR}\"" -g ${GROUP}
   cli addenv -k KUBELET_PLUGIN -v "\"${KUBELET_PLUGIN}\"" -g ${GROUP}
   
   
}

function print_usage() {
   echo "/path/kube-up.sh groupname delete|update|master|node [options].for example:\n/path/kube-up.sh configname delete\n/path/kube-up.sh configname update\n/path/kube-up.sh configname master\n/path/kube-up.sh node node_address"
}

#install_docker
case $2 in
   "delete")
      del_env
      ;;
   "update")
      del_env
      add_env
      ;;
   "master")
      cli download -f master-install.sh
      chmod +x master-install.sh
      ./master-install ${GROUP}
      ;;
   "node")
      cli download -f node-install.sh
      chmod +x node-install.sh
      ./node-install $3 ${GROUP}
      ;;
   "*")
      print_usage
      ;;
esac
