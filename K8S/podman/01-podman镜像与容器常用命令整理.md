

# Podman 常用命令分类（镜像与容器）



# 一、镜像（Image）操作命令

## 1. podman pull

**从镜像仓库下载镜像**

``` bash
podman pull docker.io/library/nginx:latest
```

**常用参数**

  参数                                                               含义
-------------------- ---------------
  --all-tags                                                     下载所有 Tag
  --arch                                                          指定 CPU 架构
  --os                                                              指定操作系统
  --tls-verify=false                                        不验证 HTTPS

------------------------------------------------------------------------

## 2. podman push

**推送镜像到镜像仓库**

``` bash
podman push alpine:v1 docker.io/user/alpine:v1
```

**常用参数**

------------------------------------------------------------------------

## 3. podman search

**在镜像仓库中搜索镜像**

``` bash
podman search nginx
```

------------------------------------------------------------------------

## 4. podman images

**列出本地所有镜像**

``` bash
podman images
podman images -q
podman images --format "{{.Repository}} {{.Tag}}"
```

**常用参数**

------------------------------------------------------------------------

## 5. podman rmi

**删除本地镜像  -f 强制删除, --prune 删除未使用的镜像**

``` bash
podman rmi nginx
podman rmi -f nginx
podman image prune
```

------------------------------------------------------------------------

## 6. podman tag

**给镜像打一个新标签**

``` bash
podman tag nginx nginx:v1
```

------------------------------------------------------------------------

## 7. podman build

**根据 Dockerfile 构建镜像**

``` bash
podman build -f Dockerfile -t python:v1
```

------------------------------------------------------------------------

## 8. podman history

**查看镜像每层 Layer**

``` bash
podman history nginx
```

------------------------------------------------------------------------

## 9. podman save

**将镜像保存为 tar 归档文件**

``` bash
podman save -o nginx.tar nginx
```

------------------------------------------------------------------------

## 10. podman load

**从 tar 归档文件加载镜像**

``` bash
podman load -i nginx.tar
```

------------------------------------------------------------------------

## 11. podman import

**从归档文件 (如容器导出文件) 导入为镜像**

``` bash
podman import rootfs.tar myimage:v1

podman import nginx.tar nginx:1.31.1
```

通常配合：

``` bash
podman export
```

---

## 12. podman export

**export 通常用于容器. 导出正在运行的容器成为镜像**

``` bash
podman export web -o web.tar

pomand export container -o image.tar
```

**与 save 的区别**

  命令                           导出对象               是否保留 Layer

--------------- ----------- ----------------

  podman save           Image                  是
  podman export       Container            否

------------------------------------------------------------------------

## 13. podman image prune

**清理未使用的镜像**

``` bash
podman image prune
podman image prune -a
```

------------------------------------------------------------------------

## 14. podman image inspect

**查看镜像的元数据（JSON 格式）**

``` bash
podman image inspect nginx
```

------------------------------------------------------------------------

## 15. podman manifest

**构建和分发"多架构"容器镜像**

``` bash
podman manifest create myapp
podman manifest add myapp docker://repo/app:amd64
podman manifest add myapp docker://repo/app:arm64
podman manifest push myapp docker://repo/app:latest
```

------------------------------------------------------------------------



# 二、容器（Container）操作命令

## 1. podman run

**创建并启动一个新容器**

``` bash
podman run -d \
  --name web \
  -p 8080:80 \
  -v /data/html:/usr/share/nginx/html:Z \
  --restart=always \
  nginx
```



```bash
 podman volume create nginx_csi
 
 podman run -d \
   --name ng_web \
   -p 8081:80 \
   -e OPTS=123456 \
   -v nginx_csi:/usr/share/nginx/html \
   --cap-drop=ALL \
   --cap-add=NET_BIND_SERVICE \
   --health-cmd="curl -f http://localhost/ || exit 1" \
   --health-start-period=20s \
   --health-interval=30s \
   --health-retries=3 \
   --restart unless-stopped \
   nginx:latest
```



常用参数：

-   -d                                                  后台运行
-   -it                                                  交互终端
-   --rm                                              退出自动删除
-   --name                                         容器名称
-   -p / -P                                            端口映射 / 随机映射所有EXPOSE端口
-   -v                                                   数据卷挂载
-   -e                                                   环境变量
-   --network                                      指定网络
-   --hostname                                   容器主机名 
-   --restart                                         重启策略（unless-stopped手动停止的不重启、always总是重启、on-failure除非人为停止等）
-   --rm                                                退出后自动删除
-   --privileged                                   特权模式(一般不需要)
-   --cap-drop=ALL                            移除容器内 Linux 进程的所有 Capability（能力），遵循最小权限原则，降低容器被攻击后的危害很多基础镜像默认已经拥有 查看容器内由哪些Capability `capsh --print`
-   --cap-add=NET_BIND_SERVICE  在容器内,允许进程绑定 1024 以下的 TCP/UDP 端口,绝大多数数据库、中间件、消息队列使用的都是 1024 以上端口，因此通常不需要
-   --memory                                      内存限制            `--memory=512m`
-   --cpus                                             限制CPU核心数   `--cpus=2`
-   --health-cmd                                 指定健康检查命令
-   --health-start-period=20s           启动期20s,检查失败不计数
-   --health-interval                           指定健康检查间隔
-   --health-retries                             连续失败多少次才认为容器不健康。

------------------------------------------------------------------------

## 2. podman create

**仅创建容器，但不启动**

``` bash
podman create --name web nginx

podman volume create --label app=nginx --label env=prod csi_nginx

podman network create --gateway 172.16.1.1 --subnet 172.16.1.0/24 web_net
```

------------------------------------------------------------------------

## 3. podman start / stop / restart

**启动/停止/重启已存在的容器**

``` bash
podman start web
podman stop web
podman restart web
```

------------------------------------------------------------------------

## 4. podman exec

**在运行中的容器内执行命令（进入容器）**

``` bash
podman exec -it web bash

podman exec -it webapp nginx -v

podman exec -it ptweb printenv
```

------------------------------------------------------------------------

## 5. podman rm

**删除容器**

``` bash
podman rm web

# 强制删除运行中的容器
podman rm -f web

# 删除卷
podman volume rm nginx_csi
# 删除所有没有在使用的卷
podman volume prune -a
```

参数：

-   -f  强制删除
-   -v 删除关联的匿名卷

------------------------------------------------------------------------

## 6. podman logs

**查看容器的日志输出**

``` bash
podman logs -f --tail 100 web
```

参数：

-   -f

------------------------------------------------------------------------

## 7. podman cp

**在容器和主机之间复制文件或目录. 不支持通配符这种写法, 如果需要批量复制文件，建议使用 `xargs` 等工具**

``` bash
podman cp ./index.html web:/usr/share/nginx/html/
podman cp web:/etc/nginx/nginx.conf ./
```

------------------------------------------------------------------------

## 8. podman inspect

**查看容器或镜像的详细元数据（JSON 格式）常用参数**

``` bash
podman inspect web

podman inspect pyweb --format '{{.State.Health.Status}}'

podman inspect pyweb --format '{{json .State.Health}}' | jq

podman inspect pyweb --format '{{.ImageName}} {{.Image}}'

podman inspect pyweb --format '{{.HostConfig.RestartPolicy.Name}}'

podman inspect --format '{{.NetworkSettings.IPAddress}}' web
```

参数：

-   --format
-   --size

------------------------------------------------------------------------

## 9. podman stats

**实时查看容器的资源使用情况**

``` bash
podman stats
podman stats --no-stream
```

显示：

-   CPU
-   Memory
-   Network IO
-   Block IO
-   PIDS

------------------------------------------------------------------------

## 10. podman port

**查看容器端口映射情况**

``` bash
podman port web
```

------------------------------------------------------------------------

## 11. podman rename

**重命名容器**

``` bash
podman rename oldname newname
```

------------------------------------------------------------------------

## 12. podman commit

**将容器的当前状态保存为镜像**

``` bash
podman commit web mynginx:v1

podman commit -m "Install vim" web mynginx:v2
```

参数：

-   -a
-   -m
-   --change

------------------------------------------------------------------------

## 13. podman diff

**查看容器的文件系统相较于镜像发生了哪些变化**

``` text
A 新增
C 修改
D 删除
```

``` bash
podman diff web
```

------------------------------------------------------------------------

## 14. podman container

**作为子命令前缀，提供容器管理子集**

``` bash
podman container ls
podman container inspect

# 删除所有停止状态的容器。
podman container prune
```
