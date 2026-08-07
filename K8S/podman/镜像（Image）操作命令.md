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

  命令            导出对象    是否保留 Layer

--------------- ----------- ----------------

  podman save     Image       是
  podman export   Container   否

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

