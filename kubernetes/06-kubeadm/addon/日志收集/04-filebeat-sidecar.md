

- sidecar模式
  - 一个容器(container)中运行了两个(pods) 使用mountPath的方式共享一块存储空间
  
  - vim strategy-blue_green.yaml
``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-green
  namespace: dev
spec:
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  selector:
    matchLabels:
      app: web-bluegreen
  replicas: 2
  template:
    metadata:
      labels:
        app: web-bluegreen
        version: v2.0
    spec:
      containers:
      - name: web-bluegreen
        image: xusx/tomcat:8.0.22-jre8
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: 1024Mi
            cpu: 100m
          limits:
            memory: 1024Mi
            cpu: 100m
        volumeMounts:
        - mountPath: /usr/local/tomcat/logs
          name: logm
      - name: filebeat
        image: xusx/filebeat:v7.14.0
        imagePullPolicy: IfNotPresent
        env:
        - name: ENV
          value: dev
        - name: PROJ_NAME
          value: tomcat
        volumeMounts:
        - mountPath: /logm
          name: logm
      volumes:
      - emptyDir: {}
        name: logm
```
