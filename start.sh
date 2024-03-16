source cfssl/cfssl-installer.sh
cd kubectl
source kubectl-installer.sh
cd ..
cd certs
source generate.sh
cd ..
cd etcd
source etcd-installer.sh
cd ..
cd certs
source ../generate-cluster-components-configs.sh
cd ..
source bootstrap-kubernetes-controller.sh
source generate-workers.sh

KUBERNETES_PUBLIC_ADDRESS="127.0.0.1"

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=/var/lib/kubernetes/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443
kubectl config set-credentials admin \
  --client-certificate=certs/admin.pem \
  --client-key=certs/admin-key.pem
kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin
kubectl config use-context kubernetes-the-hard-way

