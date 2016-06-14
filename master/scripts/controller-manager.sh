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



KUBE_CONTROLLER_MANAGER_OPTS="  \${CONTROLLER_KUBE_LOGTOSTDERR} \\
                                \${CONTROLLER_KUBE_LOG_LEVEL}   \\
                                \${CONTROLLER_KUBE_MASTER}      \\
                                \${CONTROLLER_KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE} \\
                                \${CONTROLLER_KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE}"

cat <<EOF >/usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/config
ExecStart=/opt/kubernetes/bin/kube-controller-manager ${KUBE_CONTROLLER_MANAGER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl start kube-controller-manager
