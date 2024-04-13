source /opt/canine/utils/helper.sh

OS=$(getOs)

arch=$(uname -i)
if [[ $arch == x86_64* ]]; then
    ARCH="amd64"
elif  [[ $arch == arm* ]] || [[ $arch = aarch64 ]]; then
    ARCH="arm64"
fi

wget -q --show-progress --https-only --timestamping https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_${ARCH} https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_${ARCH}
chmod +x cfssl_1.6.5_linux_${ARCH} cfssljson_1.6.5_linux_${ARCH}

if [[ $OS == "fedora" ]]; then
    sudo mv cfssl_1.6.5_linux_${ARCH} /bin/cfssl
    sudo mv cfssljson_1.6.5_linux_${ARCH} /bin/cfssljson
elif [[ $OS == "debian" ]]; then
    sudo mv cfssl_1.6.5_linux_${ARCH} /usr/local/bin/cfssl
    sudo mv cfssljson_1.6.5_linux_${ARCH} /usr/local/bin/cfssljson
fi
