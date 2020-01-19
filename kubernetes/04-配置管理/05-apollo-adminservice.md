```yaml
$ cat /data/dockerfile/apollo-adminservice/cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: apollo-adminservice-cm
  namespace: infra
data:
  application-github.properties: |
    # DataSource
    spring.datasource.url = jdbc:mysql://mysql.od.com:3306/ApolloConfigDB?characterEncoding=utf8
    spring.datasource.username = apolloconfig
    spring.datasource.password = 123456
    eureka.service.url = http://config.od.com/eureka
  app.properties: |
    appId=100003172
```

```yaml
$ cat /data/dockerfile/apollo-adminservice/dp.yaml
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: apollo-adminservice
  namespace: infra
  labels: 
    name: apollo-adminservice
spec:
  replicas: 1
  selector:
    matchLabels: 
      name: apollo-adminservice
  template:
    metadata:
      labels: 
        app: apollo-adminservice 
        name: apollo-adminservice
    spec:
      volumes:
      - name: configmap-volume
        configMap:
          name: apollo-adminservice-cm
      containers:
      - name: apollo-adminservice
        image: harbor.od.com/infra/apollo-adminservice:v1.5.1
        ports:
        - containerPort: 8080
          protocol: TCP
        volumeMounts:
        - name: configmap-volume
          mountPath: /apollo-adminservice/config
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        imagePullPolicy: IfNotPresent
      imagePullSecrets:
      - name: harbor
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      securityContext: 
        runAsUser: 0
      schedulerName: default-scheduler
  strategy:
    type: RollingUpdate
    rollingUpdate: 
      maxUnavailable: 1
      maxSurge: 1
  revisionHistoryLimit: 7
  progressDeadlineSeconds: 600
    appId=100003172
```    
    
