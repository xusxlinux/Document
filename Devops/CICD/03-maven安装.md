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
``` xml
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
        <username>admin</username>
        <password>123456</password>
    </server>
    <!-- 这里配置我们刚刚创建的user用户所对应的snapshots pom.xml文件中的id要和setting.xml相同 -->
    <server>
        <id>snapshots</id>
        <username>admin</username>
        <password>123456</password>
    </server>
  </servers>

  <mirrors>
    <mirror>
        <id>nexus</id>
        <mirrorOf>*</mirrorOf>
        <url>http://10.4.7.11:8081/repository/maven-public/</url>
    </mirror>
  </mirrors>

  <profiles>
    <!-- 配置jdk的全局配置 -->
    <profile>    
        <id>jdk8</id>    
        <activation>    
            <activeByDefault>true</activeByDefault>    
            <jdk>1.8</jdk>    
        </activation>    
        <properties>    
            <maven.compiler.source>1.8</maven.compiler.source>    
            <maven.compiler.target>1.8</maven.compiler.target>    
            <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>    
        </properties>     
    </profile> 
  </profiles>

  <activeProfiles>
    <activeProfile>jdk8</activeProfile>
  </activeProfiles>
</settings>
```
#### 手动发布 - release
``` shell
vim deploy-releases.sh 

#!/usr/bin/env bash
mvn deploy:deploy-file \
-DgroupId=org.scala-lang \
-DartifactId=scala-library \
-Dversion=2.10.5 \
-Dpackaging=jar \
-Dfile=scala-library-2.10.5.jar \
-Durl=http://10.4.7.11:8081/repository/maven-releases/ \
-DrepositoryId=releases
```

#### 手动发布 - snapshots
``` shell
vim deploy-snapshot.sh 

#!/usr/bin/env bash
mvn deploy:deploy-file \
-DgroupId=org.scala-lang \
-DartifactId=scala-library \
-Dversion=2.11.1-SNAPSHOT \
-Dpackaging=jar \
-Dfile=scala-library-2.11.1.jar \
-Durl=http://10.4.7.11:8081/repository/maven-snapshots/ \
-DrepositoryId=snapshots
```

#### 本地安装
``` shell
vim install-local.sh 

#!/usr/bin/env bash
mvn install:install-file \
-DgroupId=org.scala-lang \
-DartifactId=scala-library \
-Dversion=2.11.1-SNAPSHOT \
-Dpackaging=jar \
-Dfile=scala-library-2.11.1.jar \
-Durl=http://10.4.7.11:8081/repository/maven-snapshots/ \
-DrepositoryId=snapshots
```

#### 配置上传到nexus的 pom.xml
``` xml

```
