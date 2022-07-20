#### 下载 maven
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
#### 添加仓库到服务器上的 maven
``` shell
vim /usr/local/maven/conf/settings.xml

<?xml version="1.0" encoding="UTF-8"?>

<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

  <pluginGroups>
  </pluginGroups>

  <proxies>
  </proxies>

  <servers>
    <!-- 这里配置我们刚刚创建的user用户所对应的release pom.xml文件中的id要和setting.xml相同 -->
    <server>
        <id>releases</id>
        <user>xusx</user>
        <password>123456</password>
    </server>
    <!-- 这里配置我们刚刚创建的user用户所对应的snapshots pom.xml文件中的id要和setting.xml相同 -->
    <server>
        <id>snapshots</id>
        <user>xusx</user>
        <password>123456</password>
    </server>
  </servers>

  <mirrors>
    <!-- <mirror>
        <id>nexus-aliyun</id>
        <mirrorOf>central</mirrorOf>
        <name>Nexus aliyun</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public</url>
    </mirror> -->
    <!-- 这里配置我们线上的public仓库就行 -->
    <mirror>
        <id>nexus</id>
        <mirrorOf>*</mirrorOf>
        <url>http://10.4.7.11:8081/repository/maven-public/</url>
    </mirror>
  </mirrors>
</settings>
```

#### 配置上传到nexus的 pom.xml
``` shell

```
