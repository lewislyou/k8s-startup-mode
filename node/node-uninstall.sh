#!/bin/bash

KUBE_TEMP=${HOME}/kube_temp

function tear-down-node() {
echo "[INFO] tear-down-node"
  for service_name in kube-proxy kubelet docker flannel calico-node; 
  do
      service_file="/usr/lib/systemd/system/${service_name}.service"
     
      if [[ -f $service_file ]]; then 
          sudo systemctl stop $service_name 
          sudo systemctl disable $service_name 
          sudo rm -f $service_file
      fi

  done
  sudo rm -rf /run/flannel
  sudo rm -rf /opt/kubernetes
  sudo rm -rf ${KUBE_TEMP}
}

tear-down-node
