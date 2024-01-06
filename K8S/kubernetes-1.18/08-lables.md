
#### 标签lables

``` yaml
vim nginx-grayscale.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-nginx-new
  namespace: dev
spec:
  selector:
    matchLabels:
      app: web-nginx
  replicas: 1
  template:
    metadata:
      labels:
       app: web-nginx
    spec:
      containers:
      - name: web-nginx
        image: xusx/nginx:1.15.12
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-nginx
  namespace: dev
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: web-nginx
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web-nginx
  namespace: dev
spec:
  rules:
  - host: web-nginx.chain.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web-nginx
          servicePort: 80
```

``` shell
# 使用标签查找pod
[root@hdss7-200 k8s]# kubectl get all -n dev -l app=web-nginx
```

``` yaml
vim nginx-grayscale.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-nginx-new
  namespace: dev
spec:
  selector:
    matchLabels:
      app: web-nginx
    # matchExpressions 是一个pod的选择器条件的列表
    matchExpressions:
      - {key: group, operator: In, values: [dev, test]}
  replicas: 1
  template:
    metadata:
      labels:
       group: dev
       app: web-nginx
    spec:
      containers:
      - name: web-nginx
        image: xusx/nginx:1.15.12
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-nginx
  namespace: dev
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: web-nginx
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web-nginx
  namespace: dev
spec:
  rules:
  - host: web-nginx.chain.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web-nginx
          servicePort: 80
```

``` shell
[root@hdss7-200 k8s]# kubectl get pods -l app=web-nginx,group=dev -n dev

[root@hdss7-200 k8s]# kubectl get pods -l 'group in (dev,test)' -n dev
```

#### 给node节点打上标签
``` shell
[root@hdss7-200 k8s]# kubectl label nodes hdss7-11.host.com chain=app

[root@hdss7-200 k8s]# kubectl get nodes --show-labels hdss7-11.host.com
```

``` yaml
vim nginx-grayscale.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-nginx-new
  namespace: dev
spec:
  selector:
    matchLabels:
      app: web-nginx
    matchExpressions:
      - {key: group, operator: In, values: [dev, test]}
  replicas: 1
  template:
    metadata:
      labels:
       group: dev
       app: web-nginx
    spec:
      containers:
      - name: web-nginx
        image: xusx/nginx:1.15.12
        ports:
        - containerPort: 80
      # 在chain=app的服务器上启动容器
      nodeSelector:
        chain: app
---
apiVersion: v1
kind: Service
metadata:
  name: web-nginx
  namespace: dev
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: web-nginx
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web-nginx
  namespace: dev
spec:
  rules:
  - host: web-nginx.chain.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web-nginx
          servicePort: 80
```
