arch=$(uname -i)
if [[ $arch == x86_64* ]]; then
    ARCH="amd64"
elif  [[ $arch == arm* ]] || [[ $arch = aarch64 ]]; then
    ARCH="arm64"
fi
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl