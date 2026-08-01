
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
这些工具与开放容器倡议(OCI)是兼容的. 他们可以用于管理任何由兼容oci的容器引擎(如docker)创建的linux容器,专门为RHEL下 的单节点容器主机上运行容器而设计
```
