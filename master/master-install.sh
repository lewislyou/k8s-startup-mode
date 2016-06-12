#!/bin/bash
# common setting

CONFIG_DEFAULT_GROUP=${1:-"config"}
CONFIG_FILE_PATH="/opt/kubernetes/cfg/config"

# stop firewalld
systemctl stop firewalld
systemctl disable firewalld

cli download -f ensure-setup-dir.sh
source ensure-setup-dir.sh
cp ensure-setup-dir.sh ${KUBE_TEMP}
cd ${KUBE_TEMP}
cli download -f make-ca-cert.sh

chmod -R +x ${KUBE_TEMP}

cli download -f master.tar.gz
tar -xf master.tar.gz 
rm -f master.tar.gz

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
cli download -f master-config.sh
chmod a+x master-config.sh
./master-config.sh ${KUBE_TEMP}
echo "Done."
