> Note: The current version of the product only supports arm64 installations on linux. This is currently being tracked in issue #

To startup:

Run ```
wget https://github.com/Prathamkrishna/canine-core/archive/refs/tags/v0.0.2.tar.gz
tar -xzf v0.0.2.tar.gz
rm v0.0.2.tar.gz
cd canine-core-0.0.2
```

Execute `source ./main.sh` after downloading to set canine on local shell.

Post that, you can run the commands as per:
`canine help`.

Please run the following commands if you see the below errors:

	[WARNING FileExisting-socat]: socat not found in system path
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR FileExisting-crictl]: crictl not found in system path
	[ERROR FileExisting-conntrack]: conntrack not found in system path
	[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist
	[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1


```
VERSION=v1.26.0
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-arm64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-arm64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-arm64.tar.gz
```

Apart from the above, you will also require to install a few packages:
-> socat
-> conntrack

`echo 1 > /proc/sys/net/ipv4/ip_forward`
`modprobe br_netfilter`

