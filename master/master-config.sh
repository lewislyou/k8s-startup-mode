#!/bin/bash

KUBE_TEMP=$1
# set CONTEXT and KUBE_SERVER values for create-kubeconfig() and get-password()
source ${KUBE_TEMP}/config-default
KUBECONFIG="${HOME}/.kube/config"

if [[ ! -e "${KUBECONFIG}" ]]; then
   mkdir -p $(dirname ${KUBECONFIG})
   touch "${KUBECONFIG}"
fi
if [[ -z "${KUBE_USER}" || -z "${KUBE_PASSWORD}" ]]; then
   KUBE_USER=admin
   KUBE_PASSWORD=$(python -c 'import string,random; \
     print "".join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(16))')
fi
# set kubernetes user and password

cat << EOF > ${KUBECONFIG}
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verfy: true
    server: http://${MASTER}:8080
  name: centos
contexts:
- context:
   cluster: centos
   user: centos
  name: centos
current-context: centos
kind: Config
preferences: {}
users:
- name: centos
  user:
    password: ${KUBE_PASSWORD}
    username: ${KUBE_USER}
EOF
