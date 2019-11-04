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
```



