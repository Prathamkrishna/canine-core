> Note: The current version of the product only supports arm64 installations on linux. This is currently being tracked in issue #

Execute `source ./main.sh` after downloading to set canine on local shell.
Post that, you can run the commands as per:
`canine help`.

Please make sure to have a CRI running but for a simple use case you can run the following commands to install containerd and crictl:

```
VERSION=v1.26.0
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-arm64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-arm64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-arm64.tar.gz
```

Apart from the above, you will also require to install a few packages:
-> socat
-> conntrack
