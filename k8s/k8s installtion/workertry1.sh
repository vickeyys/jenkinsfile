#!/bin/bash
set -e

# ————————————————————————————————
# 1. Disable swap
# ————————————————————————————————
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# ————————————————————————————————
# 2. Enable IP forwarding (required for CNI like Calico)
# ————————————————————————————————
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

# ————————————————————————————————
# 3. Install required dependencies
# ————————————————————————————————
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# ————————————————————————————————
# 4. Add Docker repo for containerd
# ————————————————————————————————
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y containerd.io

# ————————————————————————————————
# 5. Configure containerd (with systemd cgroup)
# ————————————————————————————————
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# ————————————————————————————————
# 6. Add Kubernetes repo and install kubelet/kubeadm
# ————————————————————————————————
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm
sudo apt-mark hold kubelet kubeadm

echo ""
echo "✅ Kubernetes worker node setup completed!"
echo "👉 Now run the kubeadm join command (from master) to join this node."
