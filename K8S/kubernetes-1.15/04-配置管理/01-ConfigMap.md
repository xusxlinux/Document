```
停止zookeeper集群
/opt/zookeeper/bin/zkServer.sh stop

删除集群中的数据
rm -rf /data/zookeeper/logs/*
rm -rf /data/zookeeper/data/*

配置zookeeper成为单节点standalone
vim /opt/zookeeper/conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/logs
clientPort=2181
#server.1=zk1.od.com:2888:3888
#server.2=zk2.od.com:2888:3888
#server.3=zk3.od.com:2888:3888

启动zookeeper单节点
/opt/zookeeper/bin/zkServer.sh start
```

```yaml
$ cat /data/k8s-yaml/dubbo-monitor/cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dubbo-monitor-cm
  namespace: infra
data:
  dubbo.properties: |
    dubbo.container=log4j,spring,registry,jetty
    dubbo.application.name=simple-monitor
    dubbo.application.owner=xusx
    dubbo.registry.address=zookeeper://zk1.od.com:2181
    dubbo.protocol.port=20880
    dubbo.jetty.port=8080
    dubbo.jetty.directory=/dubbo-monitor-simple/monitor
    dubbo.charts.directory=/dubbo-monitor-simple/charts
    dubbo.statistics.directory=/dubbo-monitor-simple/statistics
    dubbo.log4j.file=/dubbo-monitor-simple/logs/dubbo-monitor.log
    dubbo.log4j.level=WARN
```

```yaml
 $ cat /data/k8s-yaml/dubbo-monitor/dp-cm.yaml
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: dubbo-monitor
  namespace: infra
  labels: 
    name: dubbo-monitor
spec:
  replicas: 1
  selector:
    matchLabels: 
      name: dubbo-monitor
  template:
    metadata:
      labels: 
        app: dubbo-monitor
        name: dubbo-monitor
    spec:
      containers:
      - name: dubbo-monitor
        image: harbor.od.com/infra/dubbo-monitor:latest
        ports:
        - containerPort: 8080
          protocol: TCP
        - containerPort: 20880
          protocol: TCP
        imagePullPolicy: IfNotPresent
        volumeMounts:
          - name: configmap-volume
            mountPath: /dubbo-monitor-simple/conf
      volumes:
        - name: configmap-volume
          configMap:
            name: dubbo-monitor-cm
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
 ```

```
对于格式不友好的,使用命令行的方式创建一个configmap
$ ll /opt/kubernetes/server/bin/conf/
total 20
-rw-r--r-- 1 root root 2223 Dec 18 23:22 audit.yaml
-rw------- 1 root root 6199 Dec 18 23:58 kubelet.kubeconfig
-rw------- 1 root root 6223 Dec 18 23:58 kube-proxy.kubeconfig

放在默认的命名空间
$ kubectl create configmap kubelet-cm --from-file=kubelet.kubeconfig
$ kubectl describe cm
```
