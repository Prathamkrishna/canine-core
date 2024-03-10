#!/bin/bash
echo "Greetings from canine"

print_help(){
    echo "Not enough arguments were passed. You can do one of the following next."
    echo "help: Prints the help screen"
    echo "install: prepares installation"
}

print_cluster_help(){
    echo "It seems as though no arguments were passed, you can run one of the following commands next"
    echo "create: Creates a new cluster"
    echo "delete: Deletes the current cluster"
}

create_cluster(){
    kubeadm init
}

prepare_install(){
    # check CPU > 2
    if [[ $(getconf _NPROCESSORS_ONLN) -lt 2 ]]
    then
        echo "exiting... CPU count is too low for an installation, minimum requirement for installation is 2 CPUs."
        exit 1
    fi
    echo "CPU cores verified, proceeding"
    echo "Verifying port availability"
    portAvail=$(nc 127.0.0.1 6443 -z -w5)
    exit_code=$?
    if [[ exit_code -eq 1 ]]
    then
        echo "Port is open, proceeding"
    else
        echo "Port 6443 is already occupied. Please open that port as it will be used by the kube api server."
        exit 1
    fi
    echo "Disabling swapoff for kubelet to work correctly"
    sudo swapoff -a
}

install_k8s(){
    echo "Proceeding to install kubernetes now..."
    echo "Task 1: Installing kubeadm tool"
    CNI_PLUGINS_VERSION="v1.3.0"
    ARCH="arm64"
    DEST="/opt/cni/bin"
    sudo mkdir -p "$DEST"
    curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz" | sudo tar -C "$DEST" -xz
    DOWNLOAD_DIR="/usr/local/bin"
    sudo mkdir -p "$DOWNLOAD_DIR"
    RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
    cd $DOWNLOAD_DIR
    sudo curl -L --remote-name-all https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet}
    sudo chmod +x {kubeadm,kubelet}
    RELEASE_VERSION="v0.16.2"
    curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
    sudo mkdir -p /etc/systemd/system/kubelet.service.d
    curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

    kubeadm version
    kubectl version

    echo "Task 1: Completed"
    echo "Task 2: Installing kubectl tool"

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    chmod +x /usr/local/bin/kubectl

    echo "Task 2: Completed"

    echo "Enabling kubelet service"
    systemctl enable kubelet.service

    kubeadm version
    kubectl version

    echo "Kubernetes has been installed on your machine, and the kubectl tool as well."

    echo "Please note that the local config files - canine have not been updated yet, this will be fixed with future releases."
    # have to update config.yml file
} 


if [ $# -eq 0 ]
then
    print_help
    exit 0 
fi

if [ $1 == "help" ]
then
    print_help
elif [ $1 == "install" ]
then
    prepare_install
    install_k8s
elif [ $1 == "cluster" ]
then
    if [ $# -ne 2 ]
    then
        print_cluster_help
        exit 0
    fi
    if [ $2 == "create" ]
    then
        create_cluster
    elif [ $2 == "delete" ]
    then
        echo "Deleting cluster"
    else
        print_cluster_help
    fi
else
    print_help
    echo "please enter the command that you would want to run"
fi

