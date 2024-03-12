wget -q --show-progress --https-only --timestamping https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_arm64 https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_arm64
chmod +x cfssl_1.6.5_linux_arm64 cfssljson_1.6.5_linux_arm64
sudo mv cfssl_1.6.5_linux_arm64 /usr/local/bin/cfssl
sudo mv cfssljson_1.6.5_linux_arm64 /usr/local/bin/cfssljson

