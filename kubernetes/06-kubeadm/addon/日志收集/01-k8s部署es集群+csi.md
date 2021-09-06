
vim glusterfs-storage-class.yaml
``` yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: glusterfs-storage-class
  namespace: elk
provisioner: kubernetes.io/glusterfs
allowVolumeExpansion: true
parameters:
  resturl: "http://10.4.7.200:8080"
  restauthenabled: "true"
  clusterid: "5d5dd154de3da4b4617502fd007d8a40"
  restuser: "admin"
  restuserkey: "admin@123"
  gidMin: "40000"
  gidMax: "50000"
  volumetype: "replicate:2"
```

vim es-headless-svc.yaml
``` yaml
kind: Service
apiVersion: v1
metadata:
  name: elasticsearch
  namespace: elk
  labels:
    app: elasticsearch
spec:
  selector:
    app: elasticsearch
  clusterIP: None
  ports:
    - port: 9200
      name: rest
    - port: 9300
      name: inter-node
```

vim es-statefulset.yaml
``` yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: es-cluster
  namespace: elk
spec:
  serviceName: elasticsearch
  replicas: 3
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: elasticsearch:7.14.0
        imagePullPolicy: IfNotPresent
        resources:
            limits:
              cpu: 1000m
            requests:
              cpu: 100m
        ports:
        - containerPort: 9200
          name: rest
          protocol: TCP
        - containerPort: 9300
          name: inter-node
          protocol: TCP
        volumeMounts:
        - name: es-data
          mountPath: /usr/share/elasticsearch/data
        env:
          - name: cluster.name
            value: k8s-logs
          - name: node.name
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: node.master
            value: "true"
          - name: node.data
            value: "false"
          - name: discovery.seed_hosts
            value: "es-cluster-0.elasticsearch,es-cluster-1.elasticsearch,es-cluster-2.elasticsearch"
          - name: cluster.initial_master_nodes
            value: "es-cluster-0,es-cluster-1,es-cluster-2"
          - name: ES_JAVA_OPTS
            value: "-Xms1g -Xmx1g"
      initContainers:
      - name: fix-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]
        securityContext:
          privileged: true
        volumeMounts:
        - name: es-data
          mountPath: /usr/share/elasticsearch/data
      - name: increase-vm-max-map
        image: busybox
        command: ["sysctl", "-w", "vm.max_map_count=262144"]
        securityContext:
          privileged: true
      - name: increase-fd-ulimit
        image: busybox
        command: ["sh", "-c", "ulimit -n 65536"]
        securityContext:
          privileged: true
      volumes:
        - name: es-data
          persistentVolumeClaim:
            claimName: es-data
  volumeClaimTemplates:
  - metadata:
      name: es-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: glusterfs-storage-class
      resources:
        requests:
          storage: 1Gi
```
