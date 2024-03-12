node_IP=127.0.0.1
ARCH="arm64"
curl -L -O https://dl.k8s.io/v1.9.2/kubernetes-server-linux-${ARCH}.tar.gz
tar -xzvf kubernetes-server-linux-${ARCH}.tar.gz
mkdir -p /usr/k8s/bin/
sudo cp -r kubernetes/server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler} /usr/k8s/bin/


cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/etc/kubernetes/ssl/ca-config.json \
  -profile=kubernetes kubeapi-server-cert.json | cfssljson -bare kubernetes

sudo mkdir -p /etc/kubernetes/ssl/
sudo mv kubernetes*.pem /etc/kubernetes/ssl/


BOOTSTRAP_TOKEN="khFZp2U5yWIgcjl0UsWU-cmeh05PQHXB"
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF