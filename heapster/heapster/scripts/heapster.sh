#!/bin/bash

MASTER_IP=$1
HEAPSTER_GROUP="heapster-option"
cli listenv -g ${HEAPSTER_GROUP} -e 1 > heapster-default
source ./heapster-default 

HEAPSTER_CONFIG=/opt/kubernetes/cfg/heapster

#cat <<EOF >$HEAPSTER_CONFIG
HEAPSTER_OPTS="${SOURCE} ${SINK}" 
#EOF

cat <<EOF >/usr/lib/systemd/system/heapster.service
[Unit]
Description=Heapster monitor for kubernetes

[Service]
Type=simple
#EnvironmentFile=-/opt/kubernetes/cfg/heapster
ExecStart=/opt/kubernetes/bin/heapster ${HEAPSTER_OPTS} 
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF


systemctl daemon-reload
systemctl enable heapster
systemctl start heapster

