ARCH="arm64"
wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.5.12/etcd-v3.5.12-linux-${ARCH}.tar.gz"

tar -xzvf etcd-v3.5.12-linux-${ARCH}.tar.gz

sudo mv etcd-v3.5.12-linux-${ARCH}/etcd* /usr/local/bin/

sudo mkdir -p /etc/etcd /var/lib/etcd
sudo chmod 700 /var/lib/etcd

cd ../certs
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
cd ../etcd

INTERNAL_IP="127.0.0.1"
ETCD_NAME=$(hostname -s)

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls http://${INTERNAL_IP}:2380 \\
  --listen-peer-urls http://${INTERNAL_IP}:2380 \\
  --listen-client-urls http://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls http://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${ETCD_NAME}=http://127.0.0.1:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd



sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=http://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem