## centos7.9

#### 系统优化篇
[系统优化](https://github.com/xusxlinux/Document/blob/master/kubernetes/01-%E7%8E%AF%E5%A2%83%E5%87%86%E5%A4%87.md)

#### 基础命令 yum
- 方式一 (用的比较少) 离线yum源
``` shell
[root@node-01 ~]# mount -o loop CentOS-7-x86_64-DVD-2009.iso /mnt
[root@node-01 ~]# yum-config-manager --add file:///mnt
[root@node-01 ~]# echo gpgcheck=0 >> /etc/yum.repos.d/mnt.repo
[root@node-01 ~]# yum repolist
[root@node-01 ~]# yum clean all
```
- 方式二  离线yum源
``` shell
# 在有公网的服务器上配置好需要的yum源
[root@node-01 yum.repos.d]# ll
-rw-r--r--. 1 root root 1664 Oct 23  2020 CentOS-Base.repo
-rw-r--r--  1 root root 1919 Sep 13 06:59 docker-ce.repo
-rw-r--r--  1 root root  951 Oct  3  2017 epel.repo
-rw-r--r--  1 root root 1050 Oct  3  2017 epel-testing.repo
-rw-r--r--  1 root root  192 Sep 18 20:38 nginx.repo

# 搭建本地超级本地yum源
[root@node-01 ~]# reposync -np /data/rpm
[root@node-01 ~]# yum install createrepo -y
# 到下载好的仓库执行创建命令, 把rpm包制作成yum源
[root@node-01 data]# createrepo .

[root@node-01 ~]# yum-config-manager --add file:///data/rpm
[root@node-01 ~]# echo gpgcheck=0 >> /etc/yum.repos.d/data_rpm.repo
[root@node-01 ~]# yum repolist
```
