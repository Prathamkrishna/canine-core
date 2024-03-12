sudo apt-get update
sudo apt-get -y install socat conntrack ipset

sudo swapoff -a
ARCH="arm64"

wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.28.0/crictl-v1.28.0-linux-${ARCH}.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v1.1.1/runc.${ARCH} \
  https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-${ARCH}-v1.4.0.tgz \
  https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-${ARCH}.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.28.0/bin/linux/${ARCH}/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.28.0/bin/linux/${ARCH}/kubelet

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

mkdir containerd
tar -xvf crictl-v1.28.0-linux-${ARCH}.tar.gz
tar -xvf containerd-1.7.14-linux-${ARCH}.tar.gz -C containerd
sudo tar -xvf cni-plugins-linux-${ARCH}-v1.4.0.tgz -C /opt/cni/bin/
sudo mv runc.${ARCH} runc
chmod +x crictl kube-proxy kubelet runc 
sudo mv crictl kube-proxy kubelet runc /usr/local/bin/
sudo mv containerd/bin/* /bin/