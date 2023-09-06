## 1.1 系统优化
#### 1.1 设置主机名
``` shell
xusx@localhost:~$ sudo hostnamectl set-hostname xusx.host.com
```
#### 1.2 设置历史命令
``` shell
echo 'export HISTTIMEFORMAT="%y-%m-%d %H:%M:%S "' >> ~/.bashrc
```
#### 1.3 修改时区(上海时区)
``` shell
# 修改时区
xusx@localhost:~$ sudo timedatectl set-timezone Asia/Shanghai
```
#### 1.4 更新源
``` shell
xusx@localhost:~$ sudo apt update
xusx@localhost:~$ sudo apt install -y build-essential

xusx@localhost:~$ sudo apt upgrade

xusx@localhost:~$ sudo apt list --upgradable
```
#### 1.5 修改网卡名称
``` shell
xusx@xusx:~$ sudo vim /etc/default/grub
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"

xusx@xusx:~$ sudo update-grub

# 将文件中的ens33和ens34分别改为eth0和eth1
xusx@xusx:~$ sudo vim /etc/netplan/00-installer-config.yaml
```
#### 1.5常用安装包依赖
``` shell

```

## 2.权限设置
#### 2.1 新建用户
```
# 创建用户
adduser test
```

## 3.服务器加固
#### 3.1 密钥文件
``` shell

```

## 4. 磁盘维护
``` shell
# 查看磁盘
xusx@localhost:~$ sudo -i
root@localhost:~# fdisk -l
root@localhost:~# fdisk /dev/sdc

# 硬盘格式化 
root@localhost:~# mkfs.xfs /dev/sdc1
# 查看想要挂载分区的UUID
root@localhost:~# blkid /dev/sdc1

# 临时挂载硬盘
xusx@localhost:~$ sudo mount /dev/sdc1 /data
# 卸载硬盘
xusx@localhost:~$ sudo umount /dev/sdc1

# 永久挂载硬盘(挂载UUID的方式)
xusx@localhost:~$ sudo blkid /dev/sdc1
/dev/sdc1: UUID="aa8f75ff-3ee4-4fe0-9556-e62367e4d864" BLOCK_SIZE="512" TYPE="xfs" PARTUUID="3d00e709-01"

xusx@localhost:~$ sudo vim /etc/fstab
/dev/disk/by-uuid/aa8f75ff-3ee4-4fe0-9556-e62367e4d864 /home/xusx/data xfs defaults 0 1

xusx@localhost:~$ sudo mount -a
```

## 5.安全设置(安全组)
``` shell
# 设置安全组
```
