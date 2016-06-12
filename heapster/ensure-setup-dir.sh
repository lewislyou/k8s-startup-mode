#!/bin/bash
KUBE_TEMP="${HOME}/kube_temp"

function ensure-setup-dir() {
   mkdir -p ${KUBE_TEMP}
   sudo mkdir -p /opt/kubernetes/bin
   sudo mkdir -p /opt/kubernetes/cfg
}

ensure-setup-dir
