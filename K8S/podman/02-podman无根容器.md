
``` text
Docker这家公司把libcontainer捐献出来改名叫做runc

containerd:                          高级别容器运行时
cri-o:                               高级别容器运行时
OCI:                                 谷歌和红帽等大公司,制定的规范
```


``` text
podman原来是CRI-O项目的一部分, 后来被分离成一个单独的项目叫libpod
podman的使用体验和docker类似, 不同的是podman没有daemon

简单说: alias docker=podman

运行Rootless容器
	在容器主机上, 用户能以根用户或普通用户运行容器. 非特权用户运行的容器称为无根容器
	无根容器更安全, 但有一些限制. 如, 无根容器不能通过容器主机的特权端口(1024以下的端口)发布网络服务
	可以直接作为根用户运行容器, 但这在一定程度上削弱了系统的安全性

从容器镜像运行容器
	容器从容器镜像(container image)运行, 容器镜像是创建容器的蓝图
	容器镜像打包一个应用程序联同它所有的依赖:
	系统库函数
	变成语言运行时
	编程语言库函数
	配置
	静态数据文件
	image 不可更改
	image根据规范(OCI)构建, 这些规范定义了image的格式及元数据


RHEL提供了一套容器工具:
	podman: 直接管理容器和容器image
	skopeo: 可以使用它检查, 复制, 删除,签名 image
	buildah: 可以使用它直接创建新的容器 image
这些工具与开放容器倡议(OCI)是兼容的.他们可以用于管理任何由兼容oci的容器引擎(如docker)创建的linux容器,专门为RHEL下的单节点容器主机上运行容器而设计
```
#  Rootless Podman + systemd 生产环境流程

## 1. 安装podman工具

- 其中包含了Podman、Buildah、Skopeo等全套容器工具集

```
dnf install container-tools -y
```



## 2. 新增一个python3容器

① 创建Container

```bash
podman run -it -d \
	--name pyweb \
	-p 8000:8000 \
	--health-cmd="curl -f http://0.0.0.0:8000 || exit 1" \
	--health-start-period=20s \
	--health-interval=30s \
	--health-retries=3 \
	--restart=unless-stopped \
	python:v1
```

② 生成service

``` bash
mkdir -pv ~/.config/systemd/user
cd ~/.config/systemd/user

podman generate systemd --new --files --name pyweb
```

**参数:**

- --name         容器名, 你是给哪个容器生成单元配置文件
- --files            在当前目录生成单元配置文件, 一定要cd到该目录
- --new           让systemd程序可以管理系统服务一样管理容器, 可使用enable/start/stop

③ 删除模板Container

``` bash
podman stop pyweb
podman rm pyweb
```

④重新加载

``` bash
systemctl --user daemon-reload
```

- --user  **区别**
  - systemctl start container-pyweb.service               它会去/etc/systemd/system/找container-pyweb.service
  - systemctl --user start container-pyweb.service    它会去/home/xusx/.config/systemd/user/找container-pyweb.service

⑤ 开机启动

```bash
systemctl --user enable --now container-pyweb.service
```

⑥管理python容器全部都是:

- 不要省略 `--user`，否则 `systemctl` 会到系统级的 service 目录中查找对应的服务，通常找不到你为 `Rootless Podman` 创建的用户级 service

``` bash
systemctl --user start container-pyweb.service
systemctl --user stop container-pyweb.service
systemctl --user restart container-pyweb.service
systemctl --user status container-pyweb.service
systemctl --user enable container-pyweb.service   # 如需开机自动启动
```

⑦退出xusx账户后正常运行容器. 一台机器、一个用户，只需要执行一次。以后一直有效。

``` bash
loginctl enable-linger $(whoami)

loginctl enable-linger xusx
```

- loginctl show-user xusx -p Linger         Linger=yes
- loginctl show-user xusx                          Linger=yes  说明已经开启, 以后不用再执行。这个设置写到了/var/lib/systemd/linger/xusx