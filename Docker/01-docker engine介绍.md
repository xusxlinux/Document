```
Docker基于容器技术的轻量级虚拟化解决方案
Docker是容器引擎,把Linux的cgroup、namespace等容器底层技术进行封装抽象为用户提供了创建和管理容器的便捷界面(包括命令行和API)
```

```
容器的父进程是init为 pid=1的进程
```

```
pause
1、  在docker容器中 是一个暂停的指令
$ docker pause jumpserver      # 暂停
$ docker unpause jumpserver    # 停止暂停

2、  在K8S集群中的pause容器 全称infrastucture container 基础容器
pause使用c语言编写，官方使用的镜像为gcr.io/google_containers/pause-amd64:3.0
在node节点上会起很多pause容器，和pod是一一对应,每个pod里运行一个被称为pause的容器,其他容器为业务容器,这些业务容器共享pause容器的网络栈volume挂载卷
```

```
NameSpace资源隔离

内核版本：2.6.24    PID - 进程编号                                 
内核版本：2.6.29    NET - 网络设备、网络协议栈、端口               
内核版本：2.6.19    IPC - 信号量、消息队列、共享内存               
内核版本：2.4.19    MOUNT - 文件系统，挂载点                       
内核版本：2.6.19    UTS - 主机名和域名                             
内核版本：3.8.x     USER - 操作进程的用户和用户组 
```
