[kafka 下载地址](https://archive.apache.org/dist/kafka/2.2.0/)
- 安装部署基本步骤
``` shell
wget https://archive.apache.org/dist/kafka/2.2.0/kafka_2.12-2.2.0.tgz
tar -xf kafka_2.12-2.2.0.tgz -C /data/software/
ln -vs /data/software/kafka_2.12-2.2.0 /data/kafka
mkdir -pv /data/kafka/data
```
- kafkapeiz 配置文件

  - vim /data/kafka/config/server.properties
``` cfg
############################# Server Basics #############################
# broker的id，值为整数，且必须唯一，在一个集群中不能重复
broker.id=1

############################# Socket Server Settings #############################
# kafka默认监听的端口为9092 (默认与主机名进行连接)
listeners=PLAINTEXT://:9092

# 处理网络请求的线程数量，默认为3个
num.network.threads=3

# 执行磁盘IO操作的线程数量，默认为8个
num.io.threads=8

# socket服务发送数据的缓冲区大小，默认100KB
socket.send.buffer.bytes=102400

# socket服务接受数据的缓冲区大小，默认100KB
socket.receive.buffer.bytes=102400

# socket服务所能接受的一个请求的最大大小，默认为100M
socket.request.max.bytes=104857600

############################# Log Basics #############################
# kafka存储消息数据的目录
log.dirs=/data/kafka/data

# 每个topic默认的partition数量
num.partitions=3

# 在启动时恢复数据和关闭时刷新数据时每个数据目录的线程数量
num.recovery.threads.per.data.dir=1

############################# Log Flush Policy #############################
# 消息刷新到磁盘中的消息条数阈值
#log.flush.interval.messages=10000

# 消息刷新到磁盘中的最大时间间隔,1s
#log.flush.interval.ms=1000

############################# Log Retention Policy #############################
# 日志保留小时数，超时会自动删除，默认为7天
log.retention.hours=168

# 日志保留大小，超出大小会自动删除，默认为1G
#log.retention.bytes=1073741824

# 日志分片策略，单个日志文件的大小最大为1G，超出后则创建一个新的日志文件
log.segment.bytes=1073741824

# 每隔多长时间检测数据是否达到删除条件,300s
log.retention.check.interval.ms=300000

############################# Zookeeper #############################
# Zookeeper连接信息，如果是zookeeper集群，则以逗号隔开
zookeeper.connect=hdss7-12.host.com:2181,hdss7-21.host.com:2181,hdss7-22.host.com:2181

# 连接zookeeper的超时时间,6s
zookeeper.connection.timeout.ms=6000
```
- 依次启动服务
``` shell
export KAFKA_HEAP_OPTS="-Xmx1g -Xms1g"
./kafka-server-start.sh ../config/server.properties            #启动测试
./kafka-server-start.sh -daemon ../config/server.properties    #放入后台
```
