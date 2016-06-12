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



KUBE_SCHEDULER_OPTS="   \${SCHEDULER_KUBE_LOGTOSTDERR}     \\
                        \${SCHEDULER_KUBE_LOG_LEVEL}       \\
                        \${SCHEDULER_KUBE_MASTER}          \\
			\${SCHEDULER_KUBE_SCHEDULER_LEADER_ELECT}	\\
                        \${SCHEDULER_KUBE_SCHEDULER_ARGS}"

cat <<EOF >/usr/lib/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/config
ExecStart=/opt/kubernetes/bin/kube-scheduler ${KUBE_SCHEDULER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-scheduler
systemctl start kube-scheduler
