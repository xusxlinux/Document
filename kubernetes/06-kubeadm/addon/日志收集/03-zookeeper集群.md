[zookeeper 下载地址](https://archive.apache.org/dist/zookeeper/)

- 安装部署基本步骤
``` shell
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
tar xf zookeeper-3.4.14.tar.gz
ln -vs /data/software/zookeeper-3.4.14 /data/zookeeper
mkdir -pv /data/zookeeper/{data,logs}
```

- zookeeper配置文件

  - vim /data/zookeeper/conf/zoo.cfg   （所有集群都可使用如下配置文件）

``` cfg
# 服务器之间或客户端与服务器之间维持心跳的时间间隔  tickTime以毫秒为单位。
tickTime=2000
# 集群中的follower服务器(F)与leader服务器(L)之间的初始连接心跳数
initLimit=10
# 集群中的follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数
syncLimit=5
# 数据保存目录
dataDir=/data/zookeeper/data
# 日志保存目录
dataLogDir=/data/zookeeper/logs
# 客户端连接端口
clientPort=2181
# 三个接点配置，格式为： server.服务编号=服务地址、LF通信端口、选举端口
server.1=hdss7-12.host.com:2888:3888
server.2=hdss7-21.host.com:2888:3888
server.3=hdss7-22.host.com:2888:3888
```

- 给zookeeper集群设置不同的 myid

  - vim /data/zookeeper/data/myid

``` shell
# 节点1
echo "1" > /data/zookeeper/data/myid

# 节点2
echo "2" > /data/zookeeper/data/myid

# 节点3
echo "3" > /data/zookeeper/data/myid
```

- 启动zk集群
``` shell
cd /data/zookeeper/bin
./zkServer.sh start
```
- 查看zk集群启动状态
``` shell
./zkServer.sh status
```
- 查看topic
``` shell
./kafka-topics.sh --list --zookeeper hdss7-12.host.com:2181,hdss7-21.host.com:2181,hdss7-22.host.com:2181
__consumer_offsets
k8s-filebeat-dev-logm-tomcat
```
