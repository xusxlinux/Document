#### 一、pods资源限制
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

https://feisky.gitbooks.io/kubernetes/content/components/kubelet.html

#### 二、集群方面限制pod资源 (Limits range)

``` yaml
vim limits-range.yaml

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
    defaultLimit:
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
