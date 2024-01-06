

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
              - name: discovery.seed_hosts
                value: "elasticsearch-discovery"
              - name: cluster.initial_master_nodes
                value: "elasticsearch-master-0,elasticsearch-master-1"
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
        # 在主容器启动前的操作
        initContainers:
        - name: fix-permissions
          image: busybox
          imagePullPolicy: IfNotPresent
          command: ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]
          # 设置容器为特权模式
          securityContext:
            privileged: true
          volumeMounts:
          - name: es-data
            mountPath: /usr/share/elasticsearch/data
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
              - name: node.name
                valueFrom:
                  fieldRef:
                    fieldPath: metadata.name
              - name: "network.host"
                value: "_eth0_"
  #            - name: network.publish_host
  #              value: "elasticsearch-api"
              - name: node.master
                value: "false"
              - name: node.data
                value: "true"
              - name: node.ingest
                value: "true"
              - name: discovery.seed_hosts
                value: "elasticsearch-discovery"
              - name: discovery.seed_providers
                value: "file"
              - name: http.cors.enabled
                value: "true"
              - name: http.cors.allow-origin
                value: "*"
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






