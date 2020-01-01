[jenkins官网](https://jenkins.io/zh/download/)  
[jenkins镜像](https://hub.docker.com/r/jenkins/jenkins)  

下载最新镜像
> $docker pull jenkins/jenkins:2.210
> $docker tag 5810ec636c04 harbor.od.com/public/jenkins:v2.210
> $docker push harbor.od.com/public/jenkins:v2.210

```
创建dokcerfile
$ mkdir -pv /data/dockerfile/jenkins

$ cat /data/dockerfile/jenkins/Dockerfile
FROM harbor.od.com/public/jenkins:v2.210
USER root
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    echo 'Asia/Shanghai' >/etc/timezone
ADD id_rsa /root/.ssh/id_rsa
ADD config.json /root/.docker/config.json
ADD get-docker.sh /get-docker.sh
RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config &&\
    /get-docker.sh

拷贝私钥
$ cp /root/.ssh/id_rsa .
拷贝docker仓库的认证文件
$ cp /root/.docker/config.json .
下载docker安装脚本
$ curl -fsSL get.docker.com -o get-docker.sh
$ chmod +x get-docker.sh
```
