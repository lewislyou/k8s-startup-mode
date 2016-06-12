#/bin/bash

NODE_ADDRESS=$1


mkdir -p /etc/cni/net.d
cat >/etc/cni/net.d/10-calico.conf <<EOF
{
    "name": "calico-k8s-network",
    "type": "calico",
    "etcd_authority": "${ETCD_AUTHORITY}",
    "log_level": "info",
    "ipam": {
        "type": "calico-ipam"
    }
}
EOF

mkdir -p /opt/cni/bin
cp ~/kube_temp/node/bin/calico /opt/cni/bin
chmod +x /opt/cni/bin/calico
cp ~/kube_temp/node/bin/calicoctl /opt/bin
chmod +x /opt/bin/calicoctl

cat <<EOF >/usr/lib/systemd/system/calico-node.service
[Unit]
Description=Calicoctl node
After=docker.service
Requires=docker.service

[Service]
User=root
EnvironmentFile=-/opt/kubernetes/cfg/config
PermissionsStartOnly=true
ExecStart=/opt/bin/calicoctl node  \${CALICO_NODE_IMAGE} \${CALICO_DETACH} --ip=${NODE_ADDRESS} 
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable calico-node
systemctl start calico-node 
