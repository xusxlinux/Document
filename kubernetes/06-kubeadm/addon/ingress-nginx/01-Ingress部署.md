[kubernetes  --> Ingress controller 官网](https://v1-18.docs.kubernetes.io/zh/docs/concepts/services-networking/ingress-controllers/)  
k8s项目维持的控制器[GCE](https://github.com/kubernetes/ingress-gce/blob/master/README.md)或者[nginx controllers](https://github.com/kubernetes/ingress-nginx/blob/main/README.md)   
其中如下实验使用的是[nginx controllers](https://github.com/kubernetes/ingress-nginx/blob/main/README.md)  
我选择的是GitHub上main中Tags是[nginx-30.0](https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/README.md#get-started) k8s 1.18版本使用的配置 [Getting Started](https://kubernetes.github.io/ingress-nginx/deploy/)   
版本选择参考官方文档[Ingress-nginx version](https://github.com/kubernetes/ingress-nginx/blob/main/README.md#changelog)  
[开始部署 --> 先决条件](https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/docs/deploy/index.md#prerequisite-generic-deployment-command)
- 部署ingress-controller 有两种方式
  - 不推荐 [NodePort](https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/docs/deploy/index.md#bare-metal) 因为这需要多一层转发, 影响效率
  - 推荐[ClusterIP](https://github.com/xusxlinux/Document/blob/master/kubernetes/06-kubeadm/addon/ingress-nginx/01-magic_change.yaml)需要自己魔改
  ``` yaml
  kind: DaemonSet
  
  hostNetwork: true
  nodeSelector:
    app: ingress
  ```
  - 使用DaemonSet的方式, 网络模式和标签选择器
  ``` shell
  # 需要部署在哪些节点上, 就给哪些节点打上label
  kubectl label nodes hdss7-11.host.com app=ingress
  
  # 不需要ingress的直接删除标签就行
  kubectl label nodes hdss7-11.host.com app-
  ```
- 魔改的方式还是有讲究
  ``` shell
  # 魔改之前是使用deploy方式部署的
  kubectl get all -n ingress-nginx
  
  # 删除delpy资源, 保留创建的ConfigMap , serviceaccount , clusterrole , rolebinding , clusterrolebinding
  kubectl delete deploy -n ingress-nginx nginx-ingress-controller
  
  # 或者把deploy scale缩减成零
  kubectl scale deploy -n ingress-nginx nginx-ingress-controller --replicas=0
  
  # 使用DaemonSet部署ingress
  kubectl apply -f magic_change.yaml
  ```
- 产看安装的版本信息
  ``` shell
  POD_NAMESPACE=ingress-nginx
  POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -l app.kubernetes.io/name=ingress-nginx --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')
  kubectl exec -it $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress-controller --version
  ```
- 一些不影响的报错信息
``` shell
00 +0000 UTC,DeletionTimestamp:<nil>,DeletionGracePeriodSeconds:nil,Labels:map[string]string{},Annotations:map[string]string{},OwnerReferences:[]OwnerReference{},Finalizers:[],ClusterName:,ManagedFields:[]ManagedFieldsEntry{},}, err services "ingress-nginx" not found
```
- 解决办法 - 创建一个headless
  - vim ingress-headless-svc.yaml
  ``` yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: ingress-nginx
    namespace: ingress-nginx
  spec:
    type: ClusterIP
    ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
    selector:
      app: ingress-nginx
  ```
