#!/bin/bash

echo "[-!--***--!-] Join node to Kubernetes Cluster [-!--***--!-]"

apt install -qq -y sshpass >/dev/null 2>&1

sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master.kube.com:/joincluster.sh /joincluster.sh 2>/dev/null

bash /joincluster.sh >/dev/null 2>&1
