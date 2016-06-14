#!/bin/bash

source ensure-setup-dir.sh

function tear-down-master() {
  echo "[INFO] tear-down-master on ${MASTER}"
  for service_name in kube-apiserver kube-controller-manager kube-scheduler ; do
      service_file="/usr/lib/systemd/system/${service_name}.service"
      
      if [[ -f $service_file ]]; then 
        sudo systemctl stop $service_name
        sudo systemctl disable $service_name
        sudo rm -f $service_file
      fi
  done
  sudo rm -rf /opt/kubernetes
  sudo rm -rf ${KUBE_TEMP}
}


tear-down-master
