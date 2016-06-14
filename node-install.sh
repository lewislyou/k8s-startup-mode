#!/bin/bash
set -x
if [[ $# -lt 1 ]];then
    echo "Please check your args!!"
    echo "node-install node-ip [yournamespace]"
    exit 1
else 
    hostname -I | grep "\<${1}\>" -q 2>/dev/null
    if [[ $? -ne 0 ]];then
        echo "Please check node_ip!!!"
        exit 1
    fi

fi


NODE_IP=$1
CONFIG_DEFAULT_GROUP=${2-:"config"}
CONFIG_FILE_PATH="/opt/kubernetes/cfg/config"
ROOT=$(dirname "${BASH_SOURCE}")

# stop firewalld
systemctl stop firewalld
systemctl disable firewalld

#ensure directory made

source ensure-setup-dir.sh

#source config-default
cli listenv -g ${CONFIG_DEFAULT_GROUP} > ${CONFIG_FILE_PATH}
source ${CONFIG_FILE_PATH}

cp -r ${ROOT}/node ${KUBE_TEMP}

#mk_opt by overlay_type
if [[ "${OVERLAY_TYPE}" = "flannel" ]]; then
   overlay_opt="${ETCD_SERVERS} ${FLANNEL_NET}"
else
   sudo mkdir -p /opt/bin
   cp ${KUBE_TEMP}/node/bin/calicoctl /opt/bin
   chmod +x /opt/bin
   overlay_opt="${NODE_IP}"
fi

#install node
sudo cp -r ${KUBE_TEMP}/node/bin /opt/kubernetes
sudo chmod -R +x /opt/kubernetes/bin
if [[ "${OVERLAY_TYPE}" = "flannel" ]]; then
   sudo bash ${KUBE_TEMP}/node/scripts/${OVERLAY_TYPE}.sh ${overlay_opt}
   sudo bash ${KUBE_TEMP}/node/scripts/docker.sh ${OVERLAY_TYPE}
else
   sudo bash ${KUBE_TEMP}/node/scripts/docker.sh ${OVERLAY_TYPE}
   sudo bash ${KUBE_TEMP}/node/scripts/${OVERLAY_TYPE}.sh ${overlay_opt}
fi
sudo bash ${KUBE_TEMP}/node/scripts/kubelet.sh ${NODE_IP} 
sudo bash ${KUBE_TEMP}/node/scripts/proxy.sh ${NODE_IP}
echo "Done."
