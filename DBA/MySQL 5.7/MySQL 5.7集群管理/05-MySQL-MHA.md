## MySQL- MHA

#### MHA 概述

​	MHA（MySQL Master High Availability）是由Facebook工程师开发的一款MySQL高可用软件。MHA只负责MySQL主库的高可用。
主库发生故障时，MHA会选择一个数据最接近原主库的候选节点作为新的主节点，并补齐和之前Dead Master 差异的Binlog。数据补齐之后，即将写VIP漂移到新主库上对外提供服务。

![image-20240127170553214](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20240127170553214.png)

工作原理:

- 从宕机崩溃的master保存二进制日志事件
- 识别含有最新的slave
- 应用差异的中继日志(relay log)到其他的slave；
- 应用从master保存的二进制日志事件
- 提升一个slave为新的master
- 使其他的slave连接新的master进行复制

MHA组成:

- Manager 节点：可以单独部署在一台独立的机器上管理多个master-slave集群，也可以部署在一台slave节点上
- Node 节点: 运行在每节点上

#### MHA 部署安装





#### MHA 管理工具

- 



#### MHA故障转移

- 自动故障转移
- 手动故障转移