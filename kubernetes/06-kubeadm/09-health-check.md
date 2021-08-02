#### 使用命令来检查
``` yaml
vim tomcat-health-cmd.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-tomcat-health-cmd
  namespace: dev
spec:
  selector:
    matchLabels:
      app: web-tomcat
    matchExpressions:
      - {key: group, operator: In, values: [dev, test]}
  replicas: 1
  template:
    metadata:
      labels:
       group: dev
       app: web-tomcat
    spec:
      containers:
      - name: web-tomcat
        image: xusx/tomcat:8.0.21-jre8
        ports:
        - containerPort: 8080
        # 存活性探针, 使用cmd 脚本的方式来检测
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - ps -ef | grep java|grep -v grep
          # 等待容器启动的之后在执行cmd , 等待的时间是10秒
          initialDelaySeconds: 10
          # 健康检查的间隔时间, 检查的时间越短,消耗的性能越大
          periodSeconds: 10
          # 失败几次,放弃继续检查这个容器
          failureThreshold: 2
          # 只要有一个java的进程存在, 检查就通过 
          successThreshold: 1
          # 执行上面cmd的命令时候, 最长的等待时间
          timeoutSeconds: 5
        # 就绪性探针 readinessProbe负责告诉service 应用程序可以对外访问了
        readinessProbe:
          httpGet:
            path: /
            port: 8080
            scheme: HTTP

          # 等待容器启动的之后在执行cmd , 等待的时间是10秒
          initialDelaySeconds: 10
          # 健康检查的间隔时间, 检查的时间越短,消耗的性能越大
          periodSeconds: 10
          # 失败几次,放弃继续检查这个容器
          failureThreshold: 2
          # 只要有一个java的进程存在, 检查就通过 
          successThreshold: 1
          # 执行上面cmd的命令时候, 最长的等待时间
          timeoutSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: web-tomcat
  namespace: dev
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: web-tomcat
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web-tomcat
  namespace: dev
spec:
  rules:
  - host: web-tomcat.chain.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web-tomcat
          servicePort: 8080
```

#### 使用http协议来检查
``` yaml
vim nginx-health-check.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-nginx-health
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
        # 存活性探针检测端口
        livenessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
          failureThreshold: 1
          successThreshold: 1
          timeoutSeconds: 5
        # 就绪性探针检测uri
        readinessProbe:
          httpGet:
            path: index.html
            port: 80
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 5
          failureThreshold: 1
          successThreshold: 1
          timeoutSeconds: 5
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

#### 使用tcp协议来检查
``` yaml
vim tomcat-health-tcp.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-tomcat-health-tcp
  namespace: dev
spec:
  selector:
    matchLabels:
      app: web-tomcat
    matchExpressions:
      - {key: group, operator: In, values: [dev, test]}
  replicas: 1
  template:
    metadata:
      labels:
       group: dev
       app: web-tomcat
    spec:
      containers:
      - name: web-tomcat
        image: xusx/tomcat:8.0.21-jre8
        ports:
        - containerPort: 8080
        livenessProbe:
          tcpSocket:
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
          failureThreshold: 2
          successThreshold: 1
          timeoutSeconds: 5
        # readinessProbe负责告诉service我们的应用程序可以对外访问了, 最好是检测端口
        readinessProbe:
          httpGet:
            path: /
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          failureThreshold: 2
          successThreshold: 1
          timeoutSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: web-tomcat
  namespace: dev
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: web-tomcat
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web-tomcat
  namespace: dev
spec:
  rules:
  - host: web-tomcat.chain.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web-tomcat
          servicePort: 8080
```

#### 应用
``` shell
[root@hdss7-200 k8s]# kubectl apply -f tomcat-health-cmd.yaml
[root@hdss7-200 k8s]# kubectl apply -f tomcat-health-tcp.yaml
```

