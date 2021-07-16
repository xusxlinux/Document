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
imageRepository: gcr.azk8s.cn/google-containers
```

``` yaml
外部的etcd
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.17.4
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
    podSubnet: "192.168.0.0/12"
    serviceSubnet: 172.16.0.0/16
controllerManager:
    extraArgs:
        address: 0.0.0.0
scheduler:
    extraArgs:
        address: 0.0.0.0
imageRepository: gcr.azk8s.cn/google-containers    
```

``` shell
# 开始创建k8s集群
kubeadm init --config kubeadm-config.yaml

# token24小时过期处理
kubeadm token create --print-join-command

# 不让token过期
kubeadm token create --print-join-command --ttl=0
```
