#!/bin/bash
set -x


systemctl stop docker 
systemctl stop flannel 
systemctl stop kube-proxy 
systemctl stop kubelet 
systemctl stop calico/node
