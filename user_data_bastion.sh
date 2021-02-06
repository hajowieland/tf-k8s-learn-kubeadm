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

echo "${private_key}" > /home/ubuntu/.ssh/id_rsa
chown -R ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa

cat << 'EOF' > /home/ubuntu/.ssh/config
Host *
  Protocol 2
  ConnectTimeout 10
  AddKeysToAgent yes
  SendEnv LC_ALL en_US.UTF-8
  UseRoaming no
  PubkeyAuthentication yes
  ServerAliveCountMax 20
  ServerAliveInterval 30
  StrictHostKeyChecking no

Host etcd-1
  HostName ${controller_1_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa

Host etcd-2
  HostName ${controller_2_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa

Host etcd-3
  HostName ${controller_3_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa

Host controller-1
  HostName ${controller_1_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa

Host controller-2
  HostName ${controller_2_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa

Host controller-3
  HostName ${controller_3_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa

Host worker-1
  HostName ${worker_1_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa

Host worker-2
  HostName ${worker_2_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa

Host worker-3
  HostName ${worker_3_ip}
  User ubuntu
  Port 22
  IdentityFile /home/ubuntu/.ssh/id_rsa
EOF

chown -R ubuntu:ubuntu /home/ubuntu/.ssh/config
chmod 600 /home/ubuntu/.ssh/id_rsa

wget https://gist.githubusercontent.com/dmytro/3984680/raw/1e25a9766b2f21d7a8e901492bbf9db672e0c871/ssh-multi.sh -O /home/ubuntu/ssh-multi.sh
chown -R ubuntu:ubuntu /home/ubuntu/ssh-multi.sh
chmod +x /home/ubuntu/ssh-multi.sh
