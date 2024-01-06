
- 预选策略(Predicate)
  - 排除不符合的
- 优选策略(Priority)
  - 选择最优的

- 节点的亲和性(affinity), 反亲和性(AntiAffinity)
``` yaml
vim schedule-node.yaml 

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-demo-node
  namespace: dev
spec:
  selector:
    matchLabels:
      app: web-demo-node
  replicas: 4
  template:
    metadata:
      labels:
        app: web-demo-node
    spec:
      containers:
      - name: web-demo-node
        image: xusx/tomcat:8.0.21
        ports:
        - containerPort: 8080
      # 亲和性
      affinity:
        # 节点亲和性
        nodeAffinity:
          # 必须满足下面的条件才能调度
          requiredDuringSchedulingIgnoredDuringExecution:
            # 节点的选择策略,数组形式. 如果有多个条件,需要定义多个 nodeSelectorTerms , 或者的关系
            nodeSelectorTerms:
            # 每个元素匹配一个表达式,如下. 是并且的关系, 如果有多个 matchExpressions , 要同时都满足
            - matchExpressions:
              # 节点的label名称
              - key: beta.kubernetes.io/arch
                operator: In
                values:
                - amd64
          # 最好是怎样
          preferredDuringSchedulingIgnoredDuringExecution:
          # 权重, 不是强一致的逻辑关系
          - weight: 1
            preference:
              matchExpressions:
              - key: disktype
                operator: NotIn
                values:
                - ssd
```
- pod的亲和性(affinity), 反亲和性(AntiAffinity)
``` yaml
vim schedule-pods.yaml 

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-scheduler-pod
  namespace: dev
spec:
  selector:
    matchLabels:
      app: web-scheduler-pod
  replicas: 1
  template:
    metadata:
      labels:
        app: web-scheduler-pod
    spec:
      containers:
      - name: web-scheduler-pod
        image: xusx/tomcat:8.0.21
        ports:
        - containerPort: 8080
      # 在一定区域内, 一个pod和另外一个pod的关系
      affinity:
        # 反亲和性
        #podAntiAffinity:
        # 亲和性
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-tomcat
            topologyKey: kubernetes.io/hostname
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - web-demo-node
              topologyKey: kubernetes.io/hostname
```
- 污点和污点容忍(taint)
  - 可以在node上设置一个或多个污点,拒绝pod在节点上运行. 除非pod声明了能够容忍指定的污点,否则不能够运行在该节点上.
    - 这种场景适合给某些类型, 或者某几个应用使用. 可以专门给节点打上污点. 其他pod的在调度的时候不能调度到该节点.
      - NoSchedule(调度器不会把pod调度到这个节点上)
      - NoExecute(除了不调度之外, 运行在该节点上的pod会被驱逐)
      - PreferNoSchedule(最好不要把pods调度到该node上)
``` shell
[root@hdss7-200 k8s]# kubectl taint node hdss7-11.host.com chain=test:NoSchedule
[root@hdss7-200 k8s]# kubectl taint node hdss7-12.host.com chain=dev:NoSchedule
[root@hdss7-200 k8s]# kubectl taint node hdss7-21.host.com chain=test:NoSchedule
[root@hdss7-200 k8s]# kubectl taint node hdss7-22.host.com chain=dev:NoSchedule
```
``` yaml
vim schedule-taint.yaml 

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-schedule-taint
  namespace: dev
spec:
  selector:
    matchLabels:
      app: web-schedule-taint
  replicas: 4
  template:
    metadata:
      labels:
        app: web-schedule-taint
    spec:
      containers:
      - name: web-schedule-taint
        image: xusx/nginx:1.15.12
        ports:
        - containerPort: 8080
      tolerations:
      - key: "chain"
        operator: "Equal"
        value: "test"
        effect: "NoSchedule"
```
