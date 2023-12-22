#### 登陆oracle下载jdk
[Oracle-JDK下载](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html#license-lightbox)

#### 安装jdk
``` shell
因为要认证 从官网下载到本地后上传服务器
tar xf jdk-8u202-linux-x64.tar.gz
mv jdk1.8.0_202 /usr/local/jdk

设置环境变量
vim /etc/profile
export JAVA_HOME=/usr/local/jdk  
export PATH=$JAVA_HOME/bin:$PATH  
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar  

source /etc/profile

查看版本
java -version
```

#### yum安装的jdk
``` shell
查看需要的版本
yum provides java
yum install java-1.8.0-openjdk-1.8.0.282.b08-1.1.al7.x86_64 -y

查看jdk下载位置
ls -la /etc/alternatives/java

设置yum安装的jdk环境变量
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.282.b08-1.1.al7.x86_64
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```

#### 删除openjdk
``` shell
yum list installed | grep java

yum -y remove java-1.8.0*
yum -y remove tzdata-java.noarch
yum -y remove javapackages-tools.noarch
yum -y remove python-javapackages.noarch
```

#### tomcat的systemctl管理脚本
``` shell
vim /etc/systemd/system/tomcat.service

 [Unit]
 Description=Tomcat 9 servlet container
 After=network.target

 [Service]
 Type=forking

 User=root
 Group=root

 Environment="JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.282.b08-1.1.al7.x86_64"
 Environment="JAVA_OPTS=-Djava.security.egd=file:/dev/urandom"

 Environment="CATALINA_BASE=/usr/local/tomcat"
 Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

 ExecStart=/usr/local/tomcat/bin/startup.sh
 ExecStop=/usr/local/tomcat/bin/shutdown.sh

 ExecReload=/bin/kill -s HUP $MAINPID
 ExecStop=/bin/kill -s QUIT $MAINPID

 [Install]
 WantedBy=multi-user.target
```
