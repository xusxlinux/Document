#### 登陆oracle下载jdk
[Oracle-JDK下载](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html#license-lightbox)

####  安装jdk
``` shell
因为要认证 从官网下载到本地后上传服务器
tar xf jdk-8u202-linux-x64.tar.gz
mv jdk1.8.0_202 /usr/local/java

设置环境变量
vim /etc/profile
export JAVA_HOME=/usr/local/java/
export PATH=$JAVA_HOME/bin:$PATH

source /etc/profile

查看版本
java -version
```
