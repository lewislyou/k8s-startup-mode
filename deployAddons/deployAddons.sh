#!/bin/bash

# Copyright 2015 The Kubernetes Authors All rights reserved.
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

# deploy the add-on services after the cluster is available

set -e

KUBE_ROOT=$(dirname "${BASH_SOURCE}")
source "/opt/kubernetes/cfg/config"

function init {
  echo "Creating kube-system namespace..."
  # use kubectl to create kube-system namespace
  NAMESPACE=`eval "kubectl get namespaces | grep kube-system | cat"`

  if [ ! "$NAMESPACE" ]; then
    kubectl create -f namespace.yaml 
    echo "The namespace 'kube-system' is successfully created."
  else
    echo "The namespace 'kube-system' is already there. Skipping."
  fi 

  echo
}

function deploy_dns {
  echo "Deploying DNS on Kubernetes"
  sed -e "s/{{ pillar\['dns_replicas'\] }}/${DNS_REPLICAS}/g;s/{{ pillar\['dns_domain'\] }}/${DNS_DOMAIN}/g;" "${KUBE_ROOT}/addons/dns/skydns-rc.yaml.in" > skydns-rc.yaml
  sed -e "s/{{ pillar\['dns_server'\] }}/${DNS_SERVER_IP}/g" "${KUBE_ROOT}/addons/dns/skydns-svc.yaml.in" > skydns-svc.yaml

  KUBEDNS=`eval "kubectl get services --namespace=kube-system | grep kube-dns | cat"`
      
  if [ ! "$KUBEDNS" ]; then
    # use kubectl to create skydns rc and service
    kubectl --namespace=kube-system create -f skydns-rc.yaml 
    kubectl --namespace=kube-system create -f skydns-svc.yaml

    echo "Kube-dns rc and service is successfully deployed."
  else
    echo "Kube-dns rc and service is already deployed. Skipping."
  fi

  echo
}

function deploy_ui {
  echo "Deploying Kubernetes UI..."

  KUBEUI=`eval "kubectl get services --namespace=kube-system | grep kube-ui | cat"`

  if [ ! "$KUBEUI" ]; then
    # use kubectl to create kube-ui rc and service
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/kube-ui/kube-ui-rc.yaml
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/kube-ui/kube-ui-svc.yaml

    echo "Kube-ui rc and service is successfully deployed."
  else
    echo "Kube-ui rc and service is already deployed. Skipping."
  fi

  echo
}

function deploy_monitor {
  echo "Deploying Kubernetes MORNITOR..."

  KUBEMORNITOR=`eval "kubectl get services --namespace=kube-system | grep mornitoring-grafana | cat"`

  if [ ! "$KUBEMORNITOR" ]; then
    # use kubectl to create heapster, influxdb, grafana rc and service
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/cluster-monitoring/influxdb/grafana-service.yaml
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/cluster-monitoring/influxdb/heapster-controller.yaml
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/cluster-monitoring/influxdb/heapster-service.yaml
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/cluster-monitoring/influxdb/influxdb-grafana-controller.yaml
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/cluster-monitoring/influxdb/influxdb-service.yaml

    echo "cluster mornitor: heapster, influxdb, grafana rc and service is successfully deployed."
  else
    echo "cluster mornitor: heapster, influxdb, grafana rc and service is already deployed. Skipping."
  fi

  echo
}

function deploy_logging {
  echo "Deploying Kubernetes logging..."

  KUBELOGGING=`eval "kubectl get services --namespace=kube-system | grep elasticsearch-logging | cat"`

  if [ ! "$KUBELOGGING" ]; then
    # copy fluentd-es.yaml to /etc/kubernetes/manifests
    # use kubectl to create elasticsearch, kibana rc and service
    #cp ${KUBE_ROOT}/addons/fluentd-elasticsearch/fluentd-es.yaml /etc/kubernetes/manifests
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/fluentd-elasticsearch/es-controller.yaml
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/fluentd-elasticsearch/es-service.yaml
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/fluentd-elasticsearch/kibana-controller.yaml
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/fluentd-elasticsearch/kibana-service.yaml

    echo "elasticsearch, kibana, fluentd rc and service is successfully deployed."
  else
    echo "elasticsearch, kibana, fluentd rc and service is already deployed. Skipping."
  fi

  echo
}

function deploy_kubedash {
  echo "Deploying Kubernetes KUBEDASH..."

  KUBEDASH=`eval "kubectl get services --namespace=kube-system | grep kubedash | cat"`

  if [ ! "$KUBEDASH" ]; then
    # use kubectl to create kubedash rc and service
    kubectl --namespace=kube-system create \
        -f ${KUBE_ROOT}/addons/kubedash/kube-config.yaml

    echo "Kubedash rc and service is successfully deployed."
  else
    echo "Kubedash rc and service is already deployed. Skipping."
  fi

  echo
}


pillar(){
  sed -e "s#{{ pillar\['product'\] }}#${product}#g;
          s#{{ pillar\['private_registry'\] }}#${PRIVATE_REGISTRY}#g;
          s#{{ pillar\['codis_tag'\] }}#${CODIS_TAG}#g;
          s#{{ pillar\['deploy_home'\] }}#${DEPLOY_HOME}#g;
          s#{{ pillar\['log_level'\] }}#${LOG_LEVEL}#g;
          s#{{ pillar\['proxy_replica'\] }}#${PROXY_REPLICA}#g;
          s#{{ pillar\['codis_fe_ip'\] }}#${CODIS_FE_IP}#g;
          s#{{ pillar\['codis_dashboard_limit_memory'\] }}#${CODIS_DASHBOARD_LIMIT_MEMORY}#g;
          s#{{ pillar\['codis_dashboard_limit_cpu'\] }}#${CODIS_DASHBOARD_LIMIT_CPU}#g;
          s#{{ pillar\['codis_ha_limit_memory'\] }}#${CODIS_HA_LIMIT_MEMORY}#g;
          s#{{ pillar\['codis_ha_limit_cpu'\] }}#${CODIS_HA_LIMIT_CPU}#g;
          s#{{ pillar\['codis_proxy_limit_memory'\] }}#${CODIS_PROXY_LIMIT_MEMORY}#g;
          s#{{ pillar\['codis_proxy_limit_cpu'\] }}#${CODIS_PROXY_LIMIT_CPU}#g;
          s#{{ pillar\['codis_server_g1_0_limit_memory'\] }}#${CODIS_SERVER_G1_0_LIMIT_MEMORY}#g;
          s#{{ pillar\['codis_server_g1_0_limit_cpu'\] }}#${CODIS_SERVER_G1_0_LIMIT_CPU}#g;
          s#{{ pillar\['codis_server_g1_1_limit_memory'\] }}#${CODIS_SERVER_G1_1_LIMIT_MEMORY}#g;
          s#{{ pillar\['codis_server_g1_1_limit_cpu'\] }}#${CODIS_SERVER_G1_1_LIMIT_CPU}#g;
          s#{{ pillar\['codis_resource_quota_cpu'\] }}#${CODIS_RESOURCE_QUOTA_CPU}#g;
          s#{{ pillar\['codis_resource_quota_memory'\] }}#${CODIS_RESOURCE_QUOTA_MEMORY}#g;
          s#{{ pillar\['codis_resource_quota_persistent_volume_claims'\] }}#${CODIS_RESOURCE_QUOTA_PERSISTENT_VOLUME_CLAIMS}#g;
          s#{{ pillar\['codis_resource_quota_pods'\] }}#${CODIS_RESOURCE_QUOTA_PODS}#g;
          s#{{ pillar\['codis_resource_quota_replication_controllers'\] }}#${CODIS_RESOURCE_QUOTA_REPLICATION_CONTROLLERS}#g;
          s#{{ pillar\['codis_resource_quota_resourcequotas'\] }}#${CODIS_RESOURCE_QUOTA_RESOURCEQUOTAS}#g;
          s#{{ pillar\['codis_resource_quota_secrets'\] }}#${CODIS_RESOURCE_QUOTA_SECRETS}#g;
          s#{{ pillar\['codis_resource_quota_services'\] }}#${CODIS_RESOURCE_QUOTA_SERVICES}#g;
          s#{{ pillar\['coordinator_name'\] }}#${COORDINATOR_NAME}#g;
          s#{{ pillar\['coordinator_addr'\] }}#${COORDINATOR_ADDR}#g;" $@
}

init

if [ "${ENABLE_CLUSTER_DNS}" == true ]; then
  deploy_dns
fi

if [ "${ENABLE_CLUSTER_UI}" == true ]; then
  deploy_ui
fi

if [ "${ENABLE_CLUSTER_MONITOR}" == true ]; then
  deploy_monitor
fi

if [ "${ENABLE_CLUSTER_LOGGING}" == true ]; then
  deploy_logging
fi

if [ "${ENABLE_CLUSTER_KUBEDASH}" == true ]; then
  deploy_kubedash
fi

