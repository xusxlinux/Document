

- master
  - vim es-master.yaml
``` yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: elasticsearch
    role: master
  name: elasticsearch-master
  namespace: elk
spec:
  replicas: 2
  serviceName: elasticsearch-master
  selector:
    matchLabels:
      app: elasticsearch
      role: master
  template:
    metadata:
      labels:
        app: elasticsearch
        role: master
    spec:
      serviceAccountName: es-admin
      restartPolicy: Always
      securityContext:
        fsGroup: 1000
      containers:
        - name: elasticsearch-master
          image: elasticsearch:7.14.0
          imagePullPolicy: IfNotPresent
          securityContext:
            privileged: true
          ports:
            - containerPort: 9200
              protocol: TCP
            - containerPort: 9300
              protocol: TCP
          env:
            - name: cluster.name
              value: "es_cluster"
            - name: node.master
              value: "true"
            - name: node.data
              value: "false"
            - name: discovery.seed_hosts # 旧版本使用 discovery.zen.ping.unicast.hosts
              value: "elasticsearch-discovery" # Disvocery Service
            - name: cluster.initial_master_nodes # 初始化的 master 节点，旧版本相关配置 discovery.zen.minimum_master_nodes
              value: "elasticsearch-master-0,elasticsearch-master-1" # 根据副本数和name配置
            - name: node.ingest
              value: "false"
            - name: ES_JAVA_OPTS
              value: "-Xms2g -Xmx2g"
```
 
- data
 - vim es-data.yaml
``` yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: elasticsearch
    role: data
  name: elasticsearch-data
  namespace: elk
spec:
  replicas: 2
  serviceName: elasticsearch-data
  selector:
    matchLabels:
      app: elasticsearch
      role: data
  template:
    metadata:
      labels:
        app: elasticsearch
        role: data
    spec:
      securityContext:
        fsGroup: 1000
      restartPolicy: Always
      initContainers:
      - name: configure-sysctl
        securityContext:
          runAsUser: 0
          privileged: true
        image: elasticsearch:7.14.0
        command: ["/bin/bash", "-c", "sysctl -w vm.max_map_count=262144;"]
        resources:
          {}
      containers:
        - name: elasticsearch-data
          image: elasticsearch:7.14.0
          imagePullPolicy: IfNotPresent
          securityContext:
            privileged: true
          ports:
            - containerPort: 9300
              protocol: TCP
          env:
            - name: cluster.name
              value: "es_cluster"
            - name: node.master
              value: "false"
            - name: node.data
              value: "true"
            - name: node.ingest
              value: "true"
            - name: discovery.seed_hosts
              value: "elasticsearch-discovery"
            - name: bootstrap.memory_lock  # 开启
              value: 'true'
            - name: ES_JAVA_OPTS
              value: "-Xms1g -Xmx1g"
          volumeMounts:
          - name: es-data
            mountPath: /usr/share/elasticsearch/data
      volumes:
      - name: es-data
        hostPath:
          path: /data/es-data
```

- svc
 - vim svc-es.yaml

``` yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: elasticsearch
  name: elasticsearch-discovery
  namespace: elk
spec:
  publishNotReadyAddresses: true
  ports:
  - name: transport
    port: 9300
    targetPort: 9300
  selector:
    app: elasticsearch
    role: master
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: elasticsearch
    role: data
  name: elasticsearch-api
  namespace: elk
spec:
  type: ClusterIP
  ports:
  - name: http
    protocol: TCP
    port: 9200
  selector:
    app: elasticsearch
    role: master

```




























