#!/bin/bash

echo "[---***--- STEP 01 ---***---] Pull required containers [/// Master]"
kubeadm config images pull >/dev/null 2>&1

echo "[---***--- STEP 02 ---***---] Initialize Kubernetes Cluster and pod network [/// Master]"
kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

echo "[---***--- STEP 03 ---***---] Deploy Calico network [/// Master]"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1

echo "[---***--- STEP 04 ---***---] Generate and save cluster join command to /joincluster.sh [/// Master]"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

