```
cd /usr/local/src/
wget https://github.com/coreos/flannel/releases/download/v0.10.0/flannel-v0.10.0-linux-amd64.tar.gz
tar xf flannel-v0.10.0-linux-amd64.tar.gz

scp flanneld mk-docker-opts.sh k8s-node-01:/opt/kubernetes/bin/                                                              
scp flanneld mk-docker-opts.sh k8s-node-02:/opt/kubernetes/bin/                                                                
scp flanneld mk-docker-opts.sh k8s-node-03:/opt/kubernetes/bin/
```

```
vim .flannel.sh
#!/bin/bash
# example sh .flannel.sh https://192.168.12.11:2379,https://192.168.12.12:2379,https://192.168.12.13:2379

ETCD_ENDPOINTS=${1:-"http://127.0.0.1:2379"}

cat <<EOF >/opt/kubernetes/cfg/flanneld
FLANNEL_OPTIONS="--etcd-endpoints=${ETCD_ENDPOINTS} \
-etcd-cafile=/opt/kubernetes/ssl/ca.pem \
-etcd-certfile=/opt/kubernetes/ssl/server.pem \
-etcd-keyfile=/opt/kubernetes/ssl/server-key.pem"
EOF

cat <<EOF >/usr/lib/systemd/system/flanneld.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network-online.target network.target
Before=docker.service

[Service]
Type=notify
EnvironmentFile=/opt/kubernetes/cfg/flanneld
ExecStart=/opt/kubernetes/bin/flanneld --ip-masq \$FLANNEL_OPTIONS
ExecStartPost=/opt/kubernetes/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/usr/lib/systemd/system/dockerd.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=/run/flannel/subnet.env
ExecStart=/usr/bin/dockerd \$DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP \$MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target

EOF
systemctl daemon-reload
systemctl enable flanneld
systemctl restart flanneld
systemctl restart dockerd
```
