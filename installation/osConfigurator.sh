#!/bin/bash
####################################################
echo "[---***--- STEP 01 ---***---] Disable and turn off SWAP [---***---]"
sed -i '/swap/d' /etc/fstab
swapoff -a

####################################################
echo "[---***--- STEP 02 ---***---] Stop and Disable firewall [---***---]"
systemctl disable --now ufw >/dev/null 2>&1

####################################################
echo "[---***--- STEP 03 ---***---] Enable and Load Kernel modules [---***---]"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

####################################################
echo "[---***--- STEP 04 ---***---] Add Kernel settings [---***---]"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

####################################################
echo "[---***--- STEP 05 ---***---] Install containerd runtime [---***---]"

apt update -qq >/dev/null 2>&1

apt install -qq -y ca-certificates curl gnupg lsb-release >/dev/null 2>&1

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg >/dev/null 2>&1

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -qq >/dev/null 2>&1

apt install -qq -y containerd.io >/dev/null 2>&1

containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1

####################################################
echo "[---***--- STEP 06 ---***---] Add apt repo for kubernetes [---***---]"

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1

apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

####################################################
echo "[---***--- STEP 07 ---***---] Install Kubernetes components (kubeadm, kubelet and kubectl)"

apt install -qq -y kubeadm=1.26.0-00 kubelet=1.26.0-00 kubectl=1.26.0-00 >/dev/null 2>&1

####################################################
echo "[---***--- STEP 08 ---***---] Enable ssh password authentication "

sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

####################################################
echo "[---***--- STEP 09 ---***---] Set root password "

echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1

echo "export TERM=xterm" >> /etc/bash.bashrc

####################################################
echo "[---***--- STEP 10 ---***---] Update /etc/hosts file "

cat >>/etc/hosts<<EOF
172.16.16.100   master.kube.com      master
172.16.16.101   worker-01.kube.com    worker-01
172.16.16.102   worker-02.kube.com    worker-02
EOF

