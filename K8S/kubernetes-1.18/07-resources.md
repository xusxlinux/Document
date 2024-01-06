#### 一、pods资源限制
[Resource Quotas](https://feisky.gitbooks.io/kubernetes/content/concepts/quota.html)
- Resources
  - Requests  
    表示容器希望被分配到的,可以完全保证的资源量,给到调度器,调度器会参考这个值来进行一系列的计算,从而找到最优的节点
  - Limits  
    容器能够使用的资源上限,当节点资源不足的时候,发生竞争的时候,会参考这个值来进行计算,从而进一步来决策,把哪个容器kill掉
  - Requests == Limits  
    - 当这两个值是一样的,说明服务完全可靠的,等级最高的. 
    - 不设置, 这个服务是不可靠的, 资源耗完, 优先kill
    - Requests > Limits 属于比较可靠的服务, 当资源出行竞争的时候, 按照优先级kill pod
    - cpu属于可压缩资源, 与requests有关

``` yalm
resources:
  requests:
    # 不加单位(Mi/Gi)默认的是字节数
    memory: 100Mi
    # 不加单位(m)是 100核心的cpu, 1核心的cpu = 1000m , 100m相当于0.1核cpu , 100m是绝对值,不管服务器上有多少cpu, 我能使用的只有0.1核cpu
    cpu: 100m
  limits:
    # 超过节点的使用资源, pod会处于pending状态
    memory: 100Mi
    cpu: 200m
```

``` shell
# requests 0.1cpu * 1024 =102.4 当资源发生竞争的时候,决定分配比例
docker inspect b2ca56b28d6c | grep -i cpushare
            "CpuShares": 102

# 52428800 / 1024 / 1024 = 50兆内存
docker inspect b2ca56b28d6c | grep -i memory
            "Memory": 52428800
 
# docker默认值, 转化为 100毫秒
docker inspect b2ca56b28d6c | grep -i cpuperiod
            "CpuPeriod": 100000

# limits做的,可以使用最大的cpu核心数
docker inspect b2ca56b28d6c | grep -i cpuquota
            "CpuQuota": 10000
```


#### 二、集群方面限制pod资源 (Limits range)

``` yaml
vim resource-limits-range.yaml

apiVersion: v1
kind: LimitRange
metadata:
  name: test-limits
spec:
  limits:
  - max:
      # 限制最大cpu 4核
      cpu: 4000m
      # 限制最大内存 2G
      memory: 2Gi
    min:
      # 限制制最小cpu 0.1核
      cpu: 100m
      # 限制最小内存 100兆
      memory: 100Mi
    # 限制 limit和requests最大比值不能超过多少
    maxLimitRequestRatio:
      cpu: 3
      memory: 2
    # 对type是pod的资源做了限制
    type: Pod
  - default:
      cpu: 300m
      memory: 200Mi
    defaultRequest:
      cpu: 200m
      memory: 100Mi
    max:
      cpu: 2000m
      memory: 1Gi
    min:
      cpu: 100m
      memory: 100Mi
    maxLimitRequestRatio:
      cpu: 5
      memory: 4
    # 对容器的限制
    type: Container
```


#### 三、按团队进行资源配额

``` yaml
vim resource-compute.yaml

apiVersion: v1
kind: ResourceQuota
metadata:
  name: resource-quota
  namespace: dev
spec:
  hard:
    # pods允许只有4个
    pods: 4
    requests.cpu: 2000m
    requests.memory: 4Gi
    limits.cpu: 4000m
    limits.memory: 8Gi
```

``` shell
# 如果没有配置名称空间, 可以在应用yaml的时候指定名称空间
[root@hdss7-200 ~]# kubectl apply -f resource-compute.yaml -n dev

# 查看对dev空间的资源限制
[root@hdss7-200 ~]# kubectl describe quota resource-quota -n dev
Name:            resource-quota
Namespace:       dev
Resource         Used  Hard
--------         ----  ----
limits.cpu       0     4
limits.memory    0     8Gi
pods             0     4
requests.cpu     0     2
requests.memory  0     4Gi
```

``` yaml
vim resource-object-count.yaml

apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
  namespace: dev
spec:
  hard:
    configmaps: 10
    persistentvolumeclaims: 4
    replicationcontrollers: 20
    secrets: 10
    services: 10
```

``` shell
# 查看对dev空间的资源限制
[root@hdss7-200 ~]# kubectl describe quota object-count -n dev
Name:                   object-counts
Namespace:              dev
Resource                Used  Hard
--------                ----  ----
configmaps              0     10
persistentvolumeclaims  0     4
replicationcontrollers  0     20
secrets                 1     10
services                0     10
```

#### Pod驱逐 - Eviction
- 常见驱逐策略配置
  - --eviction-soft=memory.available<1.5Gi
  - --eviction-soft-grace-period=memory.availabel=1m30s
  - --eviction-hard=memory.available<100Mi,nodefs.available<1Gi,nodefs.inodesFree<5%
- 磁盘紧缺
  - 删除死掉的pod、容器
  - 删除没用的镜像
  - 按优先级、资源占用情况驱逐pod
- 内存紧缺
  - 驱逐不可靠的pod
  - 驱逐基本可靠的pod
  - 驱逐可靠的pod
