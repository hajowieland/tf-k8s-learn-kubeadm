#! /bin/bash
hostnamectl set-hostname "$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)"
timedatectl set-timezone ${timezone}

apt-get update && apt-get install curl jq wget -y
snap install yq

ETCD_VERSION=${etcd_version}
curl -L https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz -o etcd-$ETCD_VERSION-linux-amd64.tar.gz
tar xzvf etcd-$ETCD_VERSION-linux-amd64.tar.gz
rm etcd-$ETCD_VERSION-linux-amd64.tar.gz
cd etcd-$ETCD_VERSION-linux-amd64 || exit
cp etcd /usr/local/bin/
cp etcdctl /usr/local/bin/
rm -rf etcd-$ETCD_VERSION-linux-amd64
chown ubuntu:ubuntu /usr/local/bin/etcdctl /usr/local/bin/etcd
chmod +x /usr/local/bin/etcdctl /usr/local/bin/etcd

curl -o cfssl https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/${cfssl_version}/linux/cfssl
curl -o cfssljson https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/${cfssl_version}/linux/cfssljson
mv cfssl cfssljson /usr/local/bin/
chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
chown ubuntu:ubuntu /usr/local/bin/cfssl /usr/local/bin/cfssljson
