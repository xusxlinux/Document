#### 安装java环境
$ mkdir -pv /usr/java  
$ tar xf /opt/jdk-8u221-linux-x64.tar.gz -C /usr/java/  
$ ln -sv /usr/java/jdk1.8.0_221 /usr/java/jdk  
#### 设置环境变量
$ export JAVA_HOME=/usr/java/jdk  
$ export PATH=$JAVA_HOME/bin:$JAVA_HOME/bin:$PATH  
$ export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar  

### zk的安装
[zookeeper下载地址](https://archive.apache.org/dist/zookeeper/)  
```
三个节点创建配置文件和日志的存放目录  
$ mkdir -pv /data/zookeeper/{data,logs}  

三个节点的配置文件  
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

三个节点的myid组成集群
cat /data/zookeeper/data/myid
1
cat /data/zookeeper/data/myid
2
cat /data/zookeeper/data/myid
3

三个节点启动zk
$ /opt/zookeeper/bin/zkServer.sh start

$ /opt/zookeeper/bin/zkCli.sh -server localhost:2181

ls /
```
### maven安装
```
mkdir -pv /data/nfs-volume/jenkins_home/maven-3.6.1-8u221
cp -r maven/* /data/nfs-volume/jenkins_home/maven-3.6.1-8u221


vim /data/nfs-volume/jenkins_home/maven-3.6.1-8u221/conf/settings.xml

<mirror>
  <id>nexus-aliyun</id>
  <mirrorOf>*</mirrorOf>
  <name>Nexus aliyun</name>
  <url>http://maven.aliyun.com/nexus/content/groups/public</url>
</mirror>
```
