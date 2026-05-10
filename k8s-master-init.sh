#!/bin/bash
# =========================================================
# Kubernetes Master Init Script
# Ubuntu 24.04 + Kubernetes v1.30
# =========================================================

set -e

echo "======================================="
echo " Kubernetes Master Initializer"
echo "======================================="

# ---------------------------------------------------------
# Root Check
# ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "請用 sudo 執行"
    exit 1
fi

# ---------------------------------------------------------
# Disable Swap
# ---------------------------------------------------------
echo "[1/8] Disabling swap..."

swapoff -a

sed -i '/\/swap.img/s/^/#/' /etc/fstab

# ---------------------------------------------------------
# Restart Services
# ---------------------------------------------------------
echo "[2/8] Restarting services..."

systemctl restart containerd
systemctl restart kubelet || true

# ---------------------------------------------------------
# Reset old cluster (if exists)
# ---------------------------------------------------------
echo "[3/8] Resetting old Kubernetes state..."

kubeadm reset -f || true

rm -rf /etc/cni/net.d

# ---------------------------------------------------------
# Pull Kubernetes Images
# ---------------------------------------------------------
echo "[4/8] Pulling Kubernetes images..."

kubeadm config images pull

# ---------------------------------------------------------
# Initialize Kubernetes Master
# ---------------------------------------------------------
echo "[5/8] Initializing Kubernetes master..."

kubeadm init \
--pod-network-cidr=10.244.0.0/16

# ---------------------------------------------------------
# Configure kubectl
# ---------------------------------------------------------
echo "[6/8] Configuring kubectl..."

mkdir -p /home/$SUDO_USER/.kube

cp -i /etc/kubernetes/admin.conf /home/$SUDO_USER/.kube/config

chown $(id -u $SUDO_USER):$(id -g $SUDO_USER) \
/home/$SUDO_USER/.kube/config

# ---------------------------------------------------------
# Install Flannel
# ---------------------------------------------------------
echo "[7/8] Installing Flannel CNI..."

su - $SUDO_USER -c \
"kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"

# ---------------------------------------------------------
# Show Node Status
# ---------------------------------------------------------
echo "[8/8] Checking cluster status..."

sleep 10

su - $SUDO_USER -c "kubectl get nodes"

echo ""
echo "======================================="
echo " Kubernetes Master Ready!"
echo "======================================="
echo ""
echo "接下來："
echo ""
echo "1. 到 worker 節點執行 kubeadm join"
echo ""
echo "取得 join 指令："
echo ""
echo "kubeadm token create --print-join-command"
echo ""
echo "======================================="
