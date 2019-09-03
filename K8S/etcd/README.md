
```
wget https://github.com/etcd-io/etcd/releases/download/v3.3.14/etcd-v3.3.14-linux-amd64.tar.gz
wget https://github.com/etcd-io/etcd/releases/download/v3.3.15/etcd-v3.3.15-linux-amd64.tar.gz
```
```
tar xf etcd-v3.3.15-linux-amd64.tar.gz
mv etcd-v3.3.15-linux-amd64 etcd
cd etcd/
cp etcd* /opt/kubernetes/bin/
cd /opt/kubernetes/bin/
```
```
vim .etcd.sh
#!/bin/bash
# example: sh etcd.sh etcd01 192.168.12.11 etcd02=https://192.168.12.12:2380,etcd03=https://192.168.12.13:2380

ETCD_NAME=$1
ETCD_IP=$2
ETCD_CLUSTER=$3
WORK_DIR=/opt/kubernetes

cat <<EOF >$WORK_DIR/cfg/etcd
#[Member]
ETCD_NAME="${ETCD_NAME}"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://${ETCD_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${ETCD_IP}:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_IP}:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_IP}:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://${ETCD_IP}:2380,${ETCD_CLUSTER}"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"

EOF

cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=${WORK_DIR}/cfg/etcd
ExecStart=${WORK_DIR}/bin/etcd \
--name=\${ETCD_NAME} \
--data-dir=\${ETCD_DATA_DIR} \
--listen-peer-urls=\${ETCD_LISTEN_PEER_URLS} \
--listen-client-urls=\${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \
--advertise-client-urls=\${ETCD_ADVERTISE_CLIENT_URLS} \
--initial-advertise-peer-urls=\${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
--initial-cluster=\${ETCD_INITIAL_CLUSTER} \
--initial-cluster-token=\${ETCD_INITIAL_CLUSTER_TOKEN} \
--initial-cluster-state=new \
--cert-file=${WORK_DIR}/ssl/server.pem \
--key-file=${WORK_DIR}/ssl/server-key.pem \
--peer-cert-file=${WORK_DIR}/ssl/server.pem \
--peer-key-file=${WORK_DIR}/ssl/server-key.pem \
--trusted-ca-file=${WORK_DIR}/ssl/ca.pem \
--peer-trusted-ca-file=${WORK_DIR}/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
```
```
etcdctl \
--ca-file=/opt/kubernetes/ssl/ca.pem -cert-file=/opt/kubernetes/ssl/server.pem --key-file=/opt/kubernetes/ssl/server-key.pem \
--endpoints="https://192.168.12.11:2379,https://192.168.12.12:2379,https://192.168.12.13:2379" \
cluster-health
```

#### 这个分配子网仅在etcd01上就行
```
etcdctl \
--ca-file=/opt/kubernetes/ssl/ca.pem -cert-file=/opt/kubernetes/ssl/server.pem --key-file=/opt/kubernetes/ssl/server-key.pem \
--endpoints="https://192.168.12.11:2379,https://192.168.12.12:2379,https://192.168.12.13:2379" \
set /coreos.com/network/config '{"Network": "10.0.0.0/8","Backend": {"Type": "vxlan"}}'
```
#### 出现error的原因
```
Sep  4 08:40:48 linux-node3 flanneld: E0904 08:40:48.576291    1989 main.go:349] Couldn't fetch network config: Network is too small. Minimum useful network prefix is /28


[root@linux-node1 bin]# ./etcdctl \
--ca-file=/opt/kubernetes/ssl/ca.pem -cert-file=/opt/kubernetes/ssl/server.pem --key-file=/opt/kubernetes/ssl/server-key.pem \
--endpoints="https://192.168.12.11:2379,https://192.168.12.12:2379,https://192.168.12.13:2379" \
set /coreos.com/network/config '{"Network": "10.0.0.0/8","Backend": {"Type": "vxlan"}}'


[root@linux-node1 bin]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:41:24:b1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.12.11/24 brd 192.168.12.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe41:24b1/64 scope link 
       valid_lft forever preferred_lft forever
3: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN 
    link/ether ba:22:49:ed:28:8b brd ff:ff:ff:ff:ff:ff
    inet 10.0.35.0/32 scope global flannel.1
       valid_lft forever preferred_lft forever
    inet6 fe80::b822:49ff:feed:288b/64 scope link 
       valid_lft forever preferred_lft forever
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN 
    link/ether 02:42:9e:25:fd:d0 brd ff:ff:ff:ff:ff:ff
    inet 10.0.35.1/24 brd 10.0.35.255 scope global docker0
       valid_lft forever preferred_lft forever
```
