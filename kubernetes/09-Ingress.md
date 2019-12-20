
* K8S实现了服务在集群`内`被自动发现,那如何使得服务在K8S集群`外`被使用和访问呢？
** 使用NodePort型的Service  
  注意:无法使用kube-proxy的ipvs模型,只能使用iptables模型  
** 使用Ingress  
  注意:只能调度并暴露7层应用,特指http和https协议  
* Ingress是K8S API的标准资源类型之一,也是核心资源,它其实就是一组基于域名和URL路径,把用户的请求转发至指定Service资源的规则  
* 可以将集群外部的请求流量,转发至集群内部,从而实现`服务暴露`  
* Ingress控制器是能够为Ingress资源监听某套接字,然后根据Ingress规则匹配机制路由调度流量的一个组件  
