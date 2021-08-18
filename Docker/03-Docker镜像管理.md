## 容器的基本操作
#### 一
```
登录hub.docker.com
$ docker login docker.io

搜索指定镜像
$ docker search alpine

拉取指定版本镜像
$ docker pull alpine:3.10.3

列出本地镜像
$ docker images

给镜像打标签
$ docker tag alpine:latest xusx/docker:v3.10.3

推送镜像到远程仓库
$ docker push docker.io/xusx/docker:v3.10.3

删除镜像
$ docker rmi alpine:v3.10.3

导出镜像
$ docker save xusx/alpine:v3.10.3 -o alpine.tar

导入镜像
$ docker load -i alpine.tar

将容器制作成为镜像
$ docker exec -it alpine3 sh
/ # echo hello > hello.txt
$ docker commit -p alpine3 docker.io/xusx/alpine_with_hello:v3.10.4
$ docker push docker.io/xusx/alpine_with_hello:v3.10.4

日志查看
$ docker logs -f alpine

容器参数说明
-i:          表示启动一个可交互的容器,并持续打开标准输入
-t:          表示使用终端关联到容器的标准输入输出上
-d:          表示将容器放置后台运行
--rm:        退出后即删除容器
--name:      表示定义容器唯一名称
IMAGE:       表示要运行的镜像
COMMAND:     表示启动容器时要运行的命令

$ docker run -it xusx/alpine:v3.10.3 sh
$ docker run -d xusx/alpine:v3.10.3
$ docker run --rm -it --name alpine xusx/alpine:v3.10.3 echo hello

容器的启动 停止 重启
$ docker start/stop/restart alpine
```
#### 二
```
下载nginx指定版本镜像
$ docker pull nginx:1.15.2

指定81端口映射到容器nginx的80端口
$ docker run -d -p 81:80 --name nginx nginx:1.15.2

挂载文件目录/root/html到容器的指定目录
$ docker run -d -p80:80 -v /root/html:/usr/share/nginx/html --name nginx1 nginx:1.15.2

使用随机端口映射大写的P
$ docker run -d -P -v /root/html:/usr/share/nginx/html --name nginx2 nginx:1.15.2

容器中添加环境变量
$ docker run -d -p 82:80 --name nginx3 -e ENV_OPSA=123 -e ENV_OPSB=234 nginx:1.15.2
$ docker inspect nginx3 | grep -n ENV
164:                "ENV_OPSA=123",
165:                "ENV_OPSB=234",

$ docker exec -it nginx3 /bin/bash
$ tee /etc/apt/sources.list << EOF
deb http://mirrors.163.com/debian/ jessie main non-free contrib
deb http://mirrors.163.com/debian/ jessie-updates main non-free contrib
EOF

#debian 系统更新安装jdk11
apt install dirmngr
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EA8CACC073C3DB2A
echo "deb http://ppa.launchpad.net/linuxuprising/java/ubuntu bionic main" | sudo tee /etc/apt/sources.list.d/linuxuprising-java.list
apt update
apt install oracle-java11-installer -y
apt install oracle-java11-set-default

# ubantu容器中安装curl命令
root@08d3ee0358cd:/# apt-get update && apt-get install curl -y
root@08d3ee0358cd:/# curl -k https://www.baidu.com
```
