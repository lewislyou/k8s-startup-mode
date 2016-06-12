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



KUBE_APISERVER_OPTS="   \${API_KUBE_LOGTOSTDERR}         \\
                        \${API_KUBE_LOG_LEVEL}           \\
                        \${API_KUBE_ETCD_SERVERS}        \\
                        \${API_KUBE_API_ADDRESS}         \\
                        \${API_KUBE_API_PORT}            \\
                        \${API_NODE_PORT}                \\
                        \${API_KUBE_ADVERTISE_ADDR}      \\
                        \${API_KUBE_ALLOW_PRIV}          \\
                        \${API_KUBE_SERVICE_ADDRESSES}   \\
                        \${API_KUBE_ADMISSION_CONTROL}   \\
                        \${API_KUBE_API_CLIENT_CA_FILE}  \\
			\${API_KUBE_API_TLS_CERT_FILE}   \\
			\${API_KUBE_API_TLS_PRIVATE_KEY_FILE} --runtime-config=extensions/v1beta1/daemonsets=true"


cat <<EOF >/usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/config
ExecStart=/opt/kubernetes/bin/kube-apiserver ${KUBE_APISERVER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
