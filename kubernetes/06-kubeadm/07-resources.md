
- Resources
  - Requests  
    表示容器希望被分配到的,可以完全保证的资源量,给到调度器,调度器会参考这个值来进行一系列的计算,从而找到最优的节点
  - Limits  
    容器能够使用的资源上限,当节点资源不足的时候,发生竞争的时候,会参考这个值来进行计算,从而进一步来决策,把哪个容器kill掉
    - 123

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
