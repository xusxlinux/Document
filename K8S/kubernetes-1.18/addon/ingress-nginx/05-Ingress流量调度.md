[蓝绿部署](https://github.com/xusxlinux/Document/blob/master/kubernetes/06-kubeadm/11-%E9%83%A8%E7%BD%B2%E7%AD%96%E7%95%A5.md#%E8%93%9D%E7%BB%BF%E5%8F%91%E5%B8%83)  
[金丝雀部署](https://github.com/xusxlinux/Document/blob/master/kubernetes/06-kubeadm/11-%E9%83%A8%E7%BD%B2%E7%AD%96%E7%95%A5.md#%E9%87%91%E4%B8%9D%E9%9B%80)  


#### Ingress 流量调度 策略
- vim ingress-canary-common.yaml
  ``` yaml
  apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    name: a-canary
    namespace: dev
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/rewrite-target: /$1
      nginx.ingress.kubernetes.io/rewrite-target: /
  spec:
    rules:
    - host: canary.chain.com
      http:
        paths:
        - path: /
          backend:
            serviceName: a-canary
            servicePort: 80
  ```
- vim ingress-canary-weigth.yaml
  ``` yaml
  apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    name: b-canary
    namespace: dev
    annotations:
      nginx.ingress.kubernetes.io/canary: "true"
      nginx.ingress.kubernetes.io/canary-weight: "10"
  spec:
    rules:
    - host: canary.chain.com
      http:
        paths:
        - path: /
          backend:
            serviceName: b-canary
            servicePort: 80
  ```
- vim ingress-canary-cookid.yaml

  ``` yaml
  apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    name: b-canary
    namespace: dev
    annotations:
      nginx.ingress.kubernetes.io/canary: "true"
      nginx.ingress.kubernetes.io/canary-by-cookie: "web-canary"
  spec:
    rules:
    - host: canary.chain.com
      http:
        paths:
        - path: /
          backend:
            serviceName: b-canary
            servicePort: 80
  ```
- vim ingress-canary-header.yaml
  ``` yaml
  apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    name: b-canary
    namespace: dev
    annotations:
      nginx.ingress.kubernetes.io/canary: "true"
      nginx.ingress.kubernetes.io/canary-by-header: "web-canary"
  spec:
    rules:
    - host: canary.chain.com
      http:
        paths:
        - path: /
          backend:
            serviceName: b-canary
            servicePort: 80
  ```
#### 按照优先级从上到下来
- vim ingress-canary-completely.yaml
  ``` yaml
  apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    name: b-canary
    namespace: dev
    annotations:
      nginx.ingress.kubernetes.io/canary: "true"
      nginx.ingress.kubernetes.io/canary-by-header: "web-canary"
      nginx.ingress.kubernetes.io/canary-by-cookie: "web-canary"
      nginx.ingress.kubernetes.io/canary-weight: "90"
  spec:
    rules:
    - host: canary.chain.com
      http:
        paths:
        - path: /
          backend:
            serviceName: b-canary
            servicePort: 80
  ```
