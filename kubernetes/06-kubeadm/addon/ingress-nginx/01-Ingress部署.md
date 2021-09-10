[kubernetes  --> Ingress controller 官网](https://v1-18.docs.kubernetes.io/zh/docs/concepts/services-networking/ingress-controllers/)
选择[GCE](https://github.com/kubernetes/ingress-gce/blob/master/README.md)或者[nginx controllers](https://github.com/kubernetes/ingress-nginx/blob/main/README.md)  其中如下实验使用的是[nginx controllers](https://github.com/kubernetes/ingress-nginx/blob/main/README.md)
我选择的是main中Tags是[nginx-30.0](https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/README.md#get-started) Getting Started 1.18版本使用的配置  
版本选择[Ingress-nginx version](https://github.com/kubernetes/ingress-nginx/blob/main/README.md#changelog)

[开始部署 --> 先决条件](https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/docs/deploy/index.md#prerequisite-generic-deployment-command)
- 部署ingress-controller 有两种方式
  - 不推荐 [NodePort](https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/docs/deploy/index.md#bare-metal)
  - 推荐[Cluster](https://github.com/xusxlinux/Document/blob/master/kubernetes/06-kubeadm/addon/ingress-nginx/01-magic_change.yaml)需要自己魔改
  ``` yaml
  kind: DaemonSet
  hostNetwork: true
  nodeSelector:
    app: ingress
  ```
  - 使用DaemonSet的方式, 和标签选择器
  ``` shell
  # 需要部署在哪些节点上, 就给哪些节点打上label
  kubectl label nodes hdss7-11.host.com app=ingress
  ```
