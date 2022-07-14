#### 
[maven下载地址](https://dlcdn.apache.org/maven/maven-3/)

#### 安装 maven
``` shell
下载安装 maven
wget https://dlcdn.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz --no-check-certificate
tar xf apache-maven-3.6.3-bin.tar.gz
mv apache-maven-3.6.3 /usr/local/maven

设置环境变量
vim /etc/profile
export MAVEN_HOME=/usr/local/maven
export PATH=$MAVEN_HOME/bin:$PATH

查看版本
mvn --version
```
