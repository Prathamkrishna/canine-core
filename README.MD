# Canine - A <a href="https://kubernetes.io/">kubernetes</a> installer for bare metal/private cloud environments.

Please note:
- Only supports Debian linux(and any other linux if it has `apt` installed. This is being tracked on https://github.com/Prathamkrishna/canine-core/issues/3
- Canine will install containerd by default along with runc. Future releases will have an optional CRI installer and will allow you to point to any existing CRI.
- Canine only supports a single node installation. Multiple node installer will be available with future releases for both Etcd and Kubernetes cluster.

## How to install canine?
Note: `sudo -i` Sudo into the machine and run the below commands
1. Run the following command to pull canine release onto your computer:
```
wget https://github.com/Prathamkrishna/canine-core/archive/refs/tags/canine-installer-v1-patch.tar.gz
```
2. Unzip the tar using the following command:
```
tar -xzf canine-installer-v1-patch.tar.gz
```
3. Move into the directory and initiate the installer script.
```
cd canine-core-canine-installer-v1-patch
source start.sh
```

After a complete installation, the following components will be installed:
- cfssl and cfssljson
- stacked standalone etcd cluster with single-node
- kube-apiserver, kube-controller-manager, kube-scheduler
- kubectl tool
- kubelet
- runc
- containerd
- cni-tools
- kube-proxy
- crictl

**Happy canine-ing!**
