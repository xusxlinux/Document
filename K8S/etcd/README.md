
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
