#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
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


NODE_ADDRESS=$1

KUBE_KUBELET_OPTS="   \${KUBELET_KUBE_LOGTOSTDERR}     \\
                    \${KUBELET_KUBE_LOG_LEVEL}       \\
                    --address=${NODE_ADDRESS}        \\
                    \${KUBELET_NODE_PORT}            \\
                    --hostname-override=${NODE_ADDRESS}        \\
                    \${KUBELET_API_SERVER}   \\
                    \${KUBELET_KUBE_ALLOW_PRIV}      \\
                    \${KUBELET_ARGS}	     \\
                    \${KUBELET_KUBE_DNS_SERVER}	     \\
                    \${KUBELET_KUBE_DNS_DOMAIN}	     \\
                    \${KUBELET_KUBE_CONFIG}	     \\
                    \${KUBELET_KUBE_INFRA_IMG} \${KUBELET_NET_DIR} \${KUBELET_PLUGIN} "

cat <<EOF >/usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/config
ExecStart=/opt/kubernetes/bin/kubelet ${KUBE_KUBELET_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
