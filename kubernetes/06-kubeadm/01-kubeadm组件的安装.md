#### 集群初始化配置文件
- etcd是pod状态
``` yaml
使用pod创建etcd
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.18.18
apiServer:
    certSANs:
    - "apiserver.dockerstart.com"
    - "172.16.1.185"
    - "172.16.10.89"
    - "172.16.10.90"
    - "172.16.10.91"
    extraArgs:
        allow-privileged: "true"
controlPlaneEndpoint: "apiserver.dockerstart.com:6443"
etcd:
    local:
        dataDir: /data/etcd
networking:
# This CIDR is a Flannel default. Substitute or remove for your CNI provider.
    podSubnet: "10.244.0.0/16"
controllerManager:
    extraArgs:
        address: 0.0.0.0
scheduler:
    extraArgs:
        address: 0.0.0.0
imageRepository: registry.aliyuncs.com/google_containers
```
- etcd是外部集群状态
``` yaml
外部的etcd
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.18.18
apiServer:
    certSANs:
    - "apiserver.dockerstart.com"
    - "172.16.1.185"
    - "172.16.10.89"
    - "172.16.10.90"
    - "172.16.10.91"
    extraArgs:
        allow-privileged: "true"
controlPlaneEndpoint: "apiserver.dockerstart.com:6443"
etcd:
  external:
    endpoints:
    - https://172.16.10.89:2379
    - https://172.16.10.90:2379
    - https://172.16.10.91:2379
    caFile: /opt/etcd/certs/ca.pem
    certFile: /opt/etcd/certs/etcd-peer.pem
    keyFile: /opt/etcd/certs/etcd-peer-key.pem
networking:
# This CIDR is a Flannel default. Substitute or remove for your CNI provider.
    podSubnet: "192.168.0.0/16"
    serviceSubnet: "172.16.0.0/16"
controllerManager:
    extraArgs:
        address: 0.0.0.0
scheduler:
    extraArgs:
        address: 0.0.0.0
imageRepository: registry.aliyuncs.com/google_containers
```

[k8s-kubeadm官网源](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/  )

``` shell
# 所有节点都需要安装软件
yum install yum-utils device-mapper-persistent-data lvm2 psmisc kubeadm-1.18.18-0.x86_64 kubelet-1.18.18-0.x86_64 kubectl-1.18.18-0.x86_64 -y

# 所有节点都需要开机自启动
systemctl enable --now kubelet
```

``` shell
# 只需要在第一个master节点上执行如下初始化命令
kubeadm init --config kubeadm-config.yaml

# master节点都需要创建
mkdir -pv /etc/kubernetes/pki/

# 把第一个master节点上的证书拷贝到 其他的master节点上
scp /etc/kubernetes/pki/ca.* hdss7-12:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/sa.* hdss7-12:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/front-proxy-ca.* hdss7-12:/etc/kubernetes/pki/

scp /etc/kubernetes/pki/ca.* hdss7-21:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/sa.* hdss7-21:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/front-proxy-ca.* hdss7-21:/etc/kubernetes/pki/
```

``` shell
# 加入master节点组建集群
kubeadm join apiserver.chain.com:6443 --token wbz9dp.cg20mtk73tpmkk4r \
  --discovery-token-ca-cert-hash sha256:7e00c712a461a0ae2ef897cc6fc1d9ec45efb2a324b440e45a8b849b98297e62 \
  --control-plane 

# 加入node节点组成集群
kubeadm join apiserver.chain.com:6443 --token wbz9dp.cg20mtk73tpmkk4r \
    --discovery-token-ca-cert-hash sha256:7e00c712a461a0ae2ef897cc6fc1d9ec45efb2a324b440e45a8b849b98297e62

# 在所有master节点中执行如下命令, 查看集群
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl命令补全
echo "source <(kubectl completion bash)" >> ~/.bashrc
source <(kubectl completion bash)

yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
```

``` shell
# 开始创建k8s集群
kubeadm init --config kubeadm-config.yaml

# token24小时过期处理
kubeadm token create --print-join-command

# 不让token过期
kubeadm token create --print-join-command --ttl=0
```
