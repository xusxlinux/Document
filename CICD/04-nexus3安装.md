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
