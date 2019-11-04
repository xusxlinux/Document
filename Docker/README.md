#### docker engine 的安装
```
https://docs.docker.com/install/linux/docker-ce/centos/
```

```
yum-utils提供了yum-config-manager 效用，并device-mapper-persistent-data和lvm2由需要 devicemapper存储驱动程序
$ yum install -y yum-utils \
device-mapper-persistent-data \
lvm2

使用以下命令来设置稳定的存储库
$ yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo   
http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

安装最新版本的Docker Engine-Community和containerd
$ yum install docker-ce docker-ce-cli containerd.io

查看docker engine 的历史版本
$ yum list docker-ce --showduplicates
```

```
$ vim /etc/docker/daemon.json
{
  "registry-mirrors": ["http://f1361db2.m.daocloud.io"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "insecure-registries": ["47.96.99.37"],
  "graph": "/data/docker"
}
```

```
$ vim /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100

使配置文件生效
$ sysctl -p /etc/sysctl.d/kubernetes.conf
```
