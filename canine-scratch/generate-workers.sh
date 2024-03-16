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
chmod +x crictl kube-proxy kubelet 
sudo mv crictl kube-proxy kubelet /usr/local/bin/
sudo mv containerd/bin/* /bin/

# mkdir /sys/fs/cgroup/systemd
# mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd

POD_CIDR=10.200.0.0/22
cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.4.0",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.4.0",
    "name": "lo",
    "type": "loopback"
}
EOF
sudo mkdir -p /etc/containerd/
# cat << EOF | sudo tee /etc/containerd/config.toml
# [plugins]
#   [plugins.cri.containerd]
#     snapshotter = "overlayfs"
#     [plugins.cri.containerd.default_runtime]
#       runtime_type = "io.containerd.runtime.v1.linux"
#       runtime_engine = "/usr/local/bin/runc"
#       runtime_root = ""
# EOF

mv config.toml /etc/containerd/config.toml

install -m 755 runc.${ARCH} /usr/local/sbin/runc

cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

cd certs
HOSTNAME=$(hostname -s)
sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
cd ..

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "127.0.0.1"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --cgroup-driver=cgroupfs
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cd certs
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
cd ..

cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable containerd kubelet kube-proxy
sudo systemctl start containerd kubelet kube-proxy