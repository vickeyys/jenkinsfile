#!/bin/bash

set -e

echo "🔧 Installing AWS CLI..."
sudo apt update && sudo apt install -y awscli

echo "📥 Installing kubectl..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.3/2025-04-17/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin
cp ./kubectl $HOME/bin/kubectl
export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
rm ./kubectl

echo "✅ kubectl version:"
kubectl version --client

echo "📦 Installing eksctl..."
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"

# Optional: Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_${PLATFORM}.tar.gz -C /tmp
rm eksctl_${PLATFORM}.tar.gz

sudo mv /tmp/eksctl /usr/local/bin

echo "✅ eksctl version:"
eksctl version

echo "🎉 Installation complete! You can now use aws, kubectl, and eksctl."
