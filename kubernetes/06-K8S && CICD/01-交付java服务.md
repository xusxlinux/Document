#### 安装java环境
$ mkdir -pv /usr/java  
$ tar xf /opt/jdk-8u221-linux-x64.tar.gz -C /usr/java/  
$ ln -sv /usr/java/jdk1.8.0_221 /usr/java/jdk  
# 设置环境变量
$ export JAVA_HOME=/usr/java/jdk  
$ export PATH=$JAVA_HOME/bin:$JAVA_HOME/bin:$PATH  
$ export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar  
