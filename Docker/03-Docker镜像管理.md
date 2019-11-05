## 容器的基本操作
#### 一
```
登录hub.docker.com
$ docker login docker.io

搜索指定镜像
$ docker search alpine

拉取指定版本镜像
docker pull alpine:3.10.3

列出本地镜像
docker images

给镜像打标签
docker tag alpine:latest xusx/docker:v3.10.3

推送镜像到远程仓库
docker push docker.io/xusx/docker:v3.10.3

删除镜像
docker rmi alpine:v3.10.3

导出镜像
docker save xusx/alpine:v3.10.3 -o alpine.tar

导入镜像
docker load -i alpine.tar
```
#### 二
```
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
