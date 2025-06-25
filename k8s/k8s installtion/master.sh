#!/bin/bash
set -e

# ————————————————————————————————
# 1. Disable swap (required by Kubernetes)
# ————————————————————————————————
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# ————————————————————————————————
# 2. Enable IP forwarding
# ————————————————————————————————
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# ————————————————————————————————
# 3. Install dependencies (containerd + K8s)
# ————————————————————————————————
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Docker repo for containerd
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y containerd.io

# Configure containerd with systemd cgroup driver
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# Kubernetes apt repo
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# ————————————————————————————————
# 4. Initialize Kubernetes master node
# ————————————————————————————————
sudo kubeadm init \
  --cri-socket=unix:///run/containerd/containerd.sock \
  --apiserver-advertise-address=172.31.93.155 \
  --pod-network-cidr=192.168.0.0/16   # Calico-compatible range

# Configure kubectl for current user
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
export KUBECONFIG=/etc/kubernetes/admin.conf
source ~/.bashrc

# ————————————————————————————————
# 5. Apply Calico CNI (no Flannel)
# ————————————————————————————————
echo "��� Applying Calico CNI plugin..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "✅ Kubernetes master setup with Calico completed successfully!"

