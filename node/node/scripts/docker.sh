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


OVERLAY_TYPE=${1}


if [[ ${OVERLAY_TYPE} == "flannel" ]];then
    OVERLAY=${OVERLAY_TYPE}
else
    OVERLAY="calico-node"
fi

if [[ ${OVERLAY} == "calico-node" ]];then
    REQUIRE_STRING=""
    AFTER_STRING="After=network.target"
    DISABLE_DOCKER0=""
    FLANNEL_MAKED_CONFIG=""
else
    REQUIRE_STRING="Requires=$OVERLAY.service"
    AFTER_STRING="After=network.target $OVERLAY.service" 
    DISABLE_DOCKER0="ExecStartPre=/opt/kubernetes/bin/remove-docker0.sh"
    FLANNEL_MAKED_CONFIG="EnvironmentFile=-/run/flannel/docker"
fi


cat <<EOF >/usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
${AFTER_STRING} 
${REQUIRE_STRING}

[Service]
Type=notify
${FLANNEL_MAKED_CONFIG}
EnvironmentFile=-/opt/kubernetes/cfg/config
WorkingDirectory=/opt/kubernetes/bin
${DISABLE_DOCKER0}
ExecStart=/opt/kubernetes/bin/docker daemon \$DOCKER_OPT_BIP \$DOCKER_OPT_MTU \$DOCKER_OPTS 
LimitNOFILE=1048576
LimitNPROC=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable docker
systemctl start docker
