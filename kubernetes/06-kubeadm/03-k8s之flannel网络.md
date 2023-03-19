[k8s官网-flannel](https://kubernetes.io/zh/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model)

[flannel配置文件](https://github.com/flannel-io/flannel#flannel)

#### 下载应用文件
``` shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

#### 修改 IP 地址
``` shell
# 修改默认的flannel网络地址  方式一
kubectl edit cm -n kube-system kube-flannel-cfg
    29       "Network": "192.168.0.0/16",
    37       "net-conf.json":"{\n  \"Network\": \"192.168.0.0/16\"


# 修改默认的flannel网络地址  方式二
sed -i 's#10.244.0.0/16#192.16.0.0/16#g' kube-flannel.yml
```

#### 部署flannel插件
``` shell
# 下载到本地
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml
```

## 错误锦集
``` shell
# 错误一
kube-flannel.yaml文件没有修改 IP 和kubeadm-config.yaml上的 podSubnet: "192.168.0.0/16" 一致
```
