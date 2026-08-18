# Jenkins 容器化安装部署

> 本文记录 Jenkins 的容器化部署流程，包括镜像准备、自定义 Jenkins
> 镜像构建、Docker Socket 挂载、GitLab SSH
> 连通性测试以及容器内主机名解析配置。

------------------------------------------------------------------------

## 一、部署流程概览

``` text
Jenkins 基础镜像
      │
      ▼
推送至 Harbor 私有仓库
      │
      ▼
准备 SSH 私钥 / Docker 凭据 / Docker CLI
      │
      ▼
构建自定义 Jenkins 镜像
      │
      ▼
推送至 Harbor infra 仓库
      │
      ▼
启动 Jenkins 容器
      │
      ├── 挂载 Jenkins Home
      ├── 挂载 docker.sock
      └── 配置健康检查
      │
      ▼
测试 Jenkins → GitLab SSH 连接
```

------------------------------------------------------------------------

## 二、步骤一：准备 Jenkins 基础镜像与构建文件

### 2.1 拉取 Jenkins 镜像

``` bash
docker pull crpi-r27qdou8boyf3zjk.cn-hangzhou.personal.cr.aliyuncs.com/xusx-images/jenkins:2.577
```

### 2.2 为镜像重新打标签

``` bash
docker tag \
  crpi-r27qdou8boyf3zjk.cn-hangzhou.personal.cr.aliyuncs.com/xusx-images/jenkins:2.577 \
  harbor.od.com/public/jenkins:2.55
```

### 2.3 推送至 Harbor 私有仓库

``` bash
docker push harbor.od.com/public/jenkins:2.55
```

### 2.4 创建 Jenkins Dockerfile 工作目录

``` bash
mkdir -pv /data/Dockerfile/jenkins/
cd /data/Dockerfile/jenkins/
```

### 2.5 准备 SSH 私钥

将宿主机的 SSH 私钥复制到当前构建目录，配置Jenkins 访问 gitlab仓库凭据

``` bash
cp ~/.ssh/id_rsa .
```

### 2.6 准备 Docker Registry 登录凭据

复制 Docker 的认证配置，使 Jenkins 可以访问 `harbor.od.com`私有镜像仓库。

``` bash
cp ~/.docker/config.json .
```

### 2.7 下载 Docker CLI 安装包

Docker Debian 软件包下载地址：[下载地址](https://download.docker.com/linux/debian/dists/bookworm/pool/stable/amd64/)

``` bash
wget https://download.docker.com/linux/debian/dists/bookworm/pool/stable/amd64/docker-ce-cli_24.0.0-1~debian.12~bookworm_amd64.deb
```

------------------------------------------------------------------------

## 三、步骤二：构建自定义 Jenkins 镜像

### 3.1 编写 Dockerfile

``` bash
vim Dockerfile
```

Dockerfile 内容：

``` dockerfile
FROM harbor.od.com/public/jenkins:2.577

USER root

RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone

ADD id_rsa /root/.ssh/id_rsa

ADD config.json /root/.docker/config.json

ADD containerd* docker-ce-cli* .

RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && dpkg -i *.deb
```

### 3.2 构建 Jenkins 镜像

``` bash
docker build . -t harbor.od.com/infra/jenkins:2.577
```

### 3.3 推送镜像至 Harbor

``` bash
docker push harbor.od.com/infra/jenkins:2.577
```

------------------------------------------------------------------------

## 四、步骤三：启动 Jenkins 容器

### 4.1 创建 Jenkins 数据挂载目录

Jenkins 的持久化数据保存到 `/data/nfs-volume`。

``` bash
mkdir -pv /data/nfs-volume
```

### 4.2 启动 Jenkins

同时将宿主机的 `/run/docker.sock` 挂载到 Jenkins 容器，使容器内的 Docker CLI 可以与宿主机 Docker Daemon 通信。

``` bash
docker run -it -d \
  -p 8081:8080 \
  --name jenkins \
  -v /data/nfs-volume:/var/jenkins_home \
  -v /run/docker.sock:/run/docker.sock \
  --health-cmd="curl -fsS http://jenkins.od.com/health/ || exit 1" \
  --health-start-period=20s \
  --health-interval=30s \
  --health-retries=3 \
  --restart=unless-stopped \
  harbor.od.com/infra/jenkins:2.577
```

### 4.3 关键参数说明

--------------------------------------------------------------------------
  参数                                   作用
-------------------------------------- -----------------------------------
  `-p 8081:8080`                         将宿主机 `8081` 端口映射到 Jenkins
                                         容器的 `8080`

  `--name jenkins`                       容器名称设置为 `jenkins`

  `/data/nfs-volume:/var/jenkins_home`   持久化 Jenkins 数据

  `/run/docker.sock:/run/docker.sock`    允许容器内 Docker CLI 访问宿主机Docker Daemon

  `--health-cmd`                         定义 Jenkins 健康检查命令

  `--health-start-period=20s`            容器启动后给予 20 秒初始化时间

  `--health-interval=30s`                每 30 秒执行一次健康检查

  `--health-retries=3`                   连续失败 3 次后判定为 unhealthy

  `--restart=unless-stopped`             非人为停止时自动重启容器

------------------------------------------------------------------------

## 五、测试 Jenkins 与 GitLab 的 SSH 连接

容器启动后执行：

``` bash
docker exec -it jenkins ssh -i ~/.ssh/id_rsa -T git@gitlab.od.com
```

连接成功时返回：

``` text
Welcome to GitLab, @root!
```

------------------------------------------------------------------------

## 六、处理 GitLab 主机名无法解析的问题

当前 Jenkins 以独立 Docker 容器运行时，如果无法通过现有网络解析或访问`gitlab.od.com`，可以进入 Jenkins 容器添加主机名解析。

### 6.1 进入 Jenkins 容器

``` bash
docker exec -it jenkins bash
```

### 6.2 添加 hosts 解析

``` bash
tee /etc/hosts << EOF
10.4.7.100  gitlab.od.com
EOF
```

配置完成后，可再次执行 SSH 测试：

``` bash
docker exec -it jenkins ssh -i ~/.ssh/id_rsa -T git@gitlab.od.com
```

------------------------------------------------------------------------

## 七、部署检查清单

-   [ ] Jenkins 基础镜像已准备
-   [ ] Jenkins 镜像已推送至 Harbor
-   [ ] `id_rsa` 已复制到 Dockerfile 构建目录
-   [ ] `config.json` 已复制到 Dockerfile 构建目录
-   [ ] Docker CLI 安装包已下载
-   [ ] 自定义 Jenkins 镜像构建成功
-   [ ] `harbor.od.com/infra/jenkins:2.577` 已推送
-   [ ] Jenkins Home 持久化目录已创建
-   [ ] `/run/docker.sock` 已正确挂载
-   [ ] Jenkins 容器健康检查正常
-   [ ] Jenkins 可以通过 SSH 连接 GitLab
-   [ ] `gitlab.od.com` 主机名可以正常解析

------------------------------------------------------------------------

## 八、最终目录示意

``` text
/data/
├── Dockerfile/
│   └── jenkins/
│       ├── Dockerfile
│       ├── id_rsa
│       ├── config.json
│       └── docker-ce-cli_24.0.0-1~debian.12~bookworm_amd64.deb
│
└── nfs-volume/
    └── Jenkins 持久化数据
```
