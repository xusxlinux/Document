

[k8s官网-calico](https://kubernetes.io/zh/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model)


[calico官网](https://docs.projectcalico.org/getting-started/kubernetes/quickstart)
``` shell
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
```

``` shell
# 下载到本地应用
curl https://docs.projectcalico.org/v3.11/manifests/calico.yaml -O
kubectl create -f  calico.yaml
```

``` shell
# 修改监听宿主机的eth网卡
方式一  编辑pod容器内信息
kubectl edit daemonsets.apps -n kube-system calico-node    
    53           value: interface=eth.*


方式二  编辑calico.yaml文件
vim calico.yaml        
3657               value: "interface=eth.*"
```
