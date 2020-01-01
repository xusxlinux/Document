#### 安装java环境
$ mkdir -pv /usr/java  
$ tar xf /opt/jdk-8u221-linux-x64.tar.gz -C /usr/java/  
$ ln -sv /usr/java/jdk1.8.0_221 /usr/java/jdk  
# 设置环境变量
$ export JAVA_HOME=/usr/java/jdk  
$ export PATH=$JAVA_HOME/bin:$JAVA_HOME/bin:$PATH  
$ export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar  

[zookeeper下载地址](https://archive.apache.org/dist/zookeeper/)

$ mkdir -pv /data/zookeeper/{data,logs}  
$ cat /opt/zookeeper/conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/logs
clientPort=2181
server.1=zk1.od.com:2888:3888
server.2=zk2.od.com:2888:3888
server.3=zk3.od.com:2888:3888

三个zk的myid组成集群
cat /data/zookeeper/data/myid
1
cat /data/zookeeper/data/myid
2
cat /data/zookeeper/data/myid
3



