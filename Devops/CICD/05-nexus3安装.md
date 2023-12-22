####

[nexus3下载地址](https://help.sonatype.com/repomanager3/product-information/download)
``` shell
下载安装 nexus
wget https://download.sonatype.com/nexus/3/nexus-3.40.1-01-unix.tar.gz
tar xf nexus-3.40.1-01-unix.tar.gz

mv nexus-3.40.1-01 /data/nexus
mv sonatype-work /data/

端口修改
/data/nexus/etc/nexus-default.properties

useradd nexus
chown -R nexus.nexus /data/nexus
chown -R nexus.nexus /data/sonatype-work
su - nexus -c "/data/nexus/bin/nexus start"

nexus内存和磁盘的配置
vim /data/nexus/bin/nexus.vmoptions
-Dstorage.diskCache.diskFreeSpaceLimit=2048

nexus端口的配置(需要通过nginx代理, 不能直接使用80端口)
vim /data/nexus/etc/nexus-default.properties

查看密码
cat /data/sonatype-work/nexus3/admin.password 
```

#### 私服nexus的使用
[使用教程 一](https://www.toobug.cn/post/4118.html)  
[使用教程 二](https://www.xncoding.com/2017/09/02/tool/nexus.html)

#### 把maven的包迁移到nexus上
``` shell
cat upload_m2.sh
#!usr//bin/env bash

# Maven仓库路径
REPOSITORY_PATH=~/.m2/repository

# Nexus3仓库URL
NEXUS_URL=http://10.4.7.11:8081/repository/maven-releases/

# 遍历Maven仓库中的所有文件
for file in $(find $REPOSITORY_PATH -type f -name "*.pom"); do
  # 提取相对路径
  path=${file/$REPOSITORY_PATH/}

  # 上传pom文件
  curl -v -u admin:123456 --upload-file "$file" "$NEXUS_URL$path"

  # 上传对应的jar文件
  jar=${file/.pom/.jar}
  if [ -f "$jar" ]; then
    curl -v -u admin:123456 --upload-file "$jar" "$NEXUS_URL$path"
  fi

  # 上传对应的源码文件
  sources=${file/.pom/-sources.jar}
  if [ -f "$sources" ]; then
    curl -v -u admin:123456 --upload-file "$sources" "$NEXUS_URL$path"
  fi

  # 上传对应的文档文件
  javadoc=${file/.pom/-javadoc.jar}
  if [ -f "$javadoc" ]; then
    curl -v -u admin:123456 --upload-file "$javadoc" "$NEXUS_URL$path"
  fi
done
```
