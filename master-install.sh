#!/bin/bash

CONFIG_DEFAULT_GROUP=${1:-"config"}
CONFIG_FILE_PATH="/opt/kubernetes/cfg/config"
ROOT=$(dirname "${BASH_SOURCE}")

# stop firewalld
systemctl stop firewalld
systemctl disable firewalld

source ensure-setup-dir.sh

cp make-ca-cert.sh ${KUBE_TEMP}
chmod -R +x ${KUBE_TEMP}
cp -r ${ROOT}/master ${KUBE_TEMP}

cli listenv -g ${CONFIG_DEFAULT_GROUP} > ${CONFIG_FILE_PATH}
source ${CONFIG_FILE_PATH}

#check master_ip
hostname -I | grep "\<${MASTER_IP}\>" -q 2>/dev/null
if [[ $? -ne 0 ]];then
    echo "Master_ip error!!!"
    echo "Please check config group!!!"
    exit
fi


sudo cp -r ${KUBE_TEMP}/master/bin /opt/kubernetes
sudo chmod -R +x /opt/kubernetes/bin
master_ip=${MASTER_IP}
sudo bash ${KUBE_TEMP}/make-ca-cert.sh ${master_ip} IP:${master_ip},IP:${API_SERVICE_CLUSTER_IP_RANGE%.*}.1,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local
#cd -
#bash apiserver-setup.sh 
sudo bash ${KUBE_TEMP}/master/scripts/apiserver.sh 
#bash controller-manager-setup.sh 
sudo bash ${KUBE_TEMP}/master/scripts/controller-manager.sh 
#bash scheduler-setup.sh
sudo bash ${KUBE_TEMP}/master/scripts/scheduler.sh 

./master-config.sh 
echo "Done."
